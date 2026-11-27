#define _DEFAULT_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>

#define PASS_MAX 4096
#define TOKEN_MAX 65536

struct credential {
    char   *token;
    size_t  length;
};

static int read_passphrase(char *buf, size_t size) {
    struct termios old, new;
    int fd = open("/dev/tty", O_RDWR);

    if (fd < 0)
        return -1;

    if (tcgetattr(fd, &old) < 0) {
        close(fd);
        return -1;
    }

    new = old;
    new.c_lflag &= ~ECHO;

    if (tcsetattr(fd, TCSAFLUSH, &new) < 0) {
        close(fd);
        return -1;
    }

    dprintf(fd, "GPG passphrase: ");

    ssize_t n = read(fd, buf, size - 1);

    tcsetattr(fd, TCSAFLUSH, &old);
    dprintf(fd, "\n");

    close(fd);

    if (n <= 0)
        return -1;

    if (buf[n - 1] == '\n')
        --n;

    buf[n] = '\0';

    return n ? 0 : -1;
}

int cryp_auth(const char *file, struct credential *cred) {

    int passpipe[2], outpipe[2];
    pid_t pid;
    int status;
    char passphrase[PASS_MAX] = {0};

    if (!file || !cred)
        return -1;

    cred->token = NULL;
    cred->length = 0;

    if (access(file, R_OK) != 0)
        return -1;

    if (read_passphrase(passphrase, sizeof passphrase) < 0) {
        explicit_bzero(passphrase, sizeof passphrase);
        return -1;
    }

    if (pipe(passpipe) < 0 || pipe(outpipe) < 0) {
        explicit_bzero(passphrase, sizeof passphrase);
        return -1;
    }

    pid = fork();

    if (pid < 0)
        goto error;

    if (pid == 0) {
        dup2(passpipe[0], STDIN_FILENO);
        dup2(outpipe[1], STDOUT_FILENO);

        close(passpipe[0]);
        close(passpipe[1]);
        close(outpipe[0]);
        close(outpipe[1]);

        char *argv[] = {
            "gpg",
            "--quiet",
            "--no-symkey-cache",
            "--batch",
            "--pinentry-mode",
            "loopback",
            "--passphrase-fd",
            "0",
            "--decrypt",
            (char *)file,
            NULL
        };

        execvp("gpg", argv);
        _exit(127);
    }

    close(passpipe[0]);
    close(outpipe[1]);

    /*
     * Send passphrase to GPG.
     */
    size_t plen = strlen(passphrase);

    if (write(passpipe[1], passphrase, plen) != (ssize_t)plen)
        goto parent_error;

    write(passpipe[1], "\n", 1);

    close(passpipe[1]);
    passpipe[1] = -1;

    /*
     * Erase our passphrase immediately.
     */
    explicit_bzero(passphrase, sizeof passphrase);

    /*
     * Receive decrypted credential.
     */
    char *token = malloc(TOKEN_MAX + 1);

    if (!token)
        goto parent_error;

    size_t total = 0;

    while (total < TOKEN_MAX) {
        ssize_t n = read(outpipe[0],
                         token + total,
                         TOKEN_MAX - total);

        if (n < 0 && errno == EINTR)
            continue;

        if (n <= 0)
            break;

        total += (size_t)n;
    }

    close(outpipe[0]);
    outpipe[0] = -1;

    /*
     * Check GPG exit status.
     */
    while (waitpid(pid, &status, 0) < 0) {
        if (errno != EINTR)
            goto token_error;
    }

    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
        goto token_error;

    while (total && (token[total - 1] == '\n' ||
                     token[total - 1] == '\r'))
        --total;

    if (!total || total == TOKEN_MAX ||
        memchr(token, '\0', total))
        goto token_error;

    token[total] = '\0';

    cred->token = token;
    cred->length = total;

    return 0;

token_error:
    explicit_bzero(token, TOKEN_MAX + 1);
    free(token);

    return -1;

parent_error:
    explicit_bzero(passphrase, sizeof passphrase);

    if (passpipe[1] >= 0)
        close(passpipe[1]);

    if (outpipe[0] >= 0)
        close(outpipe[0]);

    waitpid(pid, &status, 0);

    return -1;

error:
    explicit_bzero(passphrase, sizeof passphrase);

    close(passpipe[0]);
    close(passpipe[1]);
    close(outpipe[0]);
    close(outpipe[1]);

    return -1;
}

void cryp_auth_destroy(struct credential *cred) {
    if (!cred || !cred->token)
        return;

    explicit_bzero(cred->token, cred->length + 1);

    free(cred->token);

    cred->token = NULL;
    cred->length = 0;
}
