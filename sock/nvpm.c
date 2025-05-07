
#include <stddef.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <netinet/in.h>
#include <time.h>

#define GITB "git rev-parse --abbrev-ref HEAD             2> /dev/null"
#define GITS "git diff --no-ext-diff --cached --shortstat 2> /dev/null"
#define GITM "git diff --shortstat                        2> /dev/null"

int makesocket(int port){

  int server_fd, sock;
  struct sockaddr_in address;
  int opt = 1;
  socklen_t addrlen = sizeof(address);

  // Creating socket file descriptor
  if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    perror("socket failed");
    exit(EXIT_FAILURE);
  }

  if (setsockopt(server_fd, SOL_SOCKET,
     SO_REUSEADDR | SO_REUSEPORT, &opt,
     sizeof(opt))) {
    perror("setsockopt");
    exit(EXIT_FAILURE);
  }
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = INADDR_ANY;
  address.sin_port = htons(port);

  if (bind(server_fd, (struct sockaddr*)&address,sizeof(address)) < 0) {
    perror("bind failed");
    exit(EXIT_FAILURE);
  }
  if (listen(server_fd, 3) < 0) {
    perror("listen");
    exit(EXIT_FAILURE);
  }
  if ((sock=accept(server_fd,(struct sockaddr*)&address,&addrlen))<0) {
    perror("accept");
    exit(EXIT_FAILURE);
  }
  return sock;
}
char* readcomm(const char *comm){

  FILE *fp=popen(comm,"r");
  if (!fp) return NULL;
  char *info = malloc(50*sizeof(char));
  int i=0;
    
  while(fgets(info, sizeof(info),fp)!= NULL);

  return info;
}

int main(int argc, char const* argv[]) {

  if (argc!=3) perror("E01");

  int delay = atoi(argv[1]);
  int port  = atoi(argv[2]);

  delay = delay<100?100:delay;
  delay*= 1000;

  int socket = makesocket(port);

  while(1){

    char* gitb = readcomm(GITB);
    char* gits = readcomm(GITS);
    char* gitm = readcomm(GITM);

    char* b="gitless";
    char* s="0";
    char* m="0";
    char* c="1";
    int modified=0,staged=0;
    if (gitb!=NULL){
      b=gitb;
    }
    if (gits!=NULL){
      s="1";
      staged=1;
    }
    if (gitm!=NULL){
      m="1";
      modified=1;
    }
    if (modified||staged){
      c="0";
    }

    char* data = malloc(56*sizeof(char));

    strcat(data,b);
    strcat(data,",");
    strcat(data,m);
    strcat(data,",");
    strcat(data,s);
    strcat(data,",");
    strcat(data,c);

    send(socket, data, strlen(data), 0);
    usleep(delay);
  }

  return 0;
}

