
let s:nvpm = '../nvpm/'
let s:nvim = 'nvim/'
let s:root = './'

fu! menu#sync(...) "{

  " sync   files {

    let msg  = 'menu.sync: sync files? [esc closes it] '
    let user = input(msg,'yes','customlist,menu#yesn')
    if empty(user)||user==?'no'|return 1|else
      let pairs = [
      \#{orig: 'auto/' , dest: 'autoload/' },
      \#{orig: 'plug/' , dest: 'plugin/'   },
      \#{orig: 'synx/' , dest: 'syntax/'   },
      \#{orig: 'colr/' , dest: 'colors/'   },
      \#{orig: 'help/' , dest: 'doc/'      },
      \]
      for pair in pairs
        let orig = s:nvim..pair.orig
        let dest = s:nvpm..pair.dest
        if isdirectory(orig)
          let files = readdir(orig)
          for file in files
            " TODO: remove this when new version is ready
            if file=='nvpm.vim'|continue|endif
            call menu#SYNC(orig..file,dest..file)
          endfor
        endif
      endfor
      call menu#SYNC('nvim/vers' , '../nvpm/version')
      call menu#SYNC('nvim/read' , '../nvpm/README.md')
      call menu#SYNC('lice'      , '../nvpm/LICENSE')
    endif

  "}
  " push   changes {

    ec "\n"
    let msg  = 'menu.sync: push files? [esc closes it] '
    let user = input(msg,'yes','customlist,menu#yesn')
    if empty(user)||user==?'no'|return 1|else
      call menu#push('nvpm')
    endif

  "}

endfu "}
fu! menu#push(...) "{

  let root = get(a:000,0,'devl')

  if -1==flux#find('nvpm|devl',root)|return 1|endif

  ec "\n"
  ec repeat('-',&columns)
  call menu#save(root)

  " retrive token {

    let server = 'gitlab'
    let server = 'github'
    let tfile  = $'/iasj/cryp/{server}'
    let token  = $'/iasj/cryp/{server}.gpg'
    let prefix = ['',"gitlab-cli-token:"][server=='gitlab']
    if filereadable(tfile)|call delete(tfile)|endif
    echo "\n"
    echo $'Pushing main -> {root}'
    let pass = inputsecret('type the passphrase: ')
    if empty(pass)|return 1|endif
    let command = 'gpg -q --no-symkey-cache --batch --passphrase '
    let command.= pass..' '..token
    call system(command)
    if v:shell_error
      echohl Error
      echo "\nWrong passphrase"
      echohl None
      return 1
    endif

  " }
  "" push w/ token {
  "
  "  if filereadable(tfile)
  "    let token = readfile(tfile)[0]
  "    call delete(tfile)
  "    let url = $'https://{prefix}{token}@{server}.com/nvpm/{root}'
  "    let flag = '--force '.url.' main --tags'
  "    ec "\n"
  "    ec repeat('-',&columns)
  "    echohl NVPMPassed
  "    ec system('git -C '..menu#fixd(root)..' push '.flag)
  "    echohl None
  "    ec repeat('-',&columns)
  "  endif
  "
  "" }

endfu "}
fu! menu#save(...) "{

  let root = get(a:000,0,'devl')
  let root = menu#fixd(root)
  if !isdirectory(root..'/.git')
    call system('git -C '..root..' init')
  endif
  let status = system('git -C '..root..' status --porcelain')
  if empty(status)
    echohl DiffAdded
    echo 'Clean Working Directory ('..root..'). Aborting commit...'
    echohl None
    return 0
  else
    echohl Error
    echo 'Modified content at ('..root..')'
    echohl None
  endif
  echo repeat('-',&columns)

  let same = 0
  let msg  = ''
  let tag  = ''
  if root==s:nvpm
    let vers = root..'version'
    if filereadable(vers)
      let vers = readfile(vers)
      if !empty(vers)
        let msg  = vers[0]
        let last = system('git -C '..root..' log -1 --pretty=%B')
        let last = trim(last)
        let tag  = trim(matchstr(msg,'\m^v\x\+\.0\.0'))
        if msg==last
          let same = 1
          let msg  = ''
        endif
      endif
    endif
  endif

  if empty(msg)&&!same
    ec "type commit message for ("..root..")"
    let msg = input('>>> ')
    if empty(msg)|return 0|endif
    ec "\n"
  endif

  echo system($'git -C {root} add .')
  echo "\n"
  echo system($'git -C {root} commit -m "{msg}"')

  if !empty(tag)&&root==s:nvpm
    echo "\n"
    echo $'created tag {tag} at {root}'
    call system($'git -C {root} tag {tag}')
  endif

endfu "}
fu! menu#make(...) "{

  echo repeat('-',&columns)
  let plug = input('menu.make: new plugin name [esc closes it] ')
  if empty(plug)|return 1|endif

  " create files {

    let plug = tolower(plug)
    let PLUG = toupper(plug)

    let autoload = [
    \'" auto/'..plug,
    \'" once {',
    \'',
    \'if !NVPMTEST&&exists("__'..PLUG..'AUTO__")|finish|endif',
    \'let __'..PLUG..'AUTO__ = 1',
    \'',
    \'" end-once}',
    \'" func {',
    \'',
    \'fu! '.plug.'#'.plug.'(...) "'..repeat(' ',59)..'{',
    \'endfu "}',
    \'',
    \'" end-func}',
    \]
    let plugin = [
    \'" plug/'..plug,
    \'" once {',
    \'',
    \'if !NVPMTEST&&exists("__'..PLUG..'PLUG__")|finish|endif',
    \'let __'..PLUG..'PLUG__ = 1',
    \'',
    \'" end-once}',
    \'" cmds {',
    \'" end-cmds }',
    \'" acmd {',
    \'" end-acmd }',
    \]

    call menu#MAKE(autoload,'nvim/auto/'..plug..'.vim')
    call menu#MAKE(plugin  ,'nvim/plug/'..plug..'.vim')

  "}

endfu "}

" Helping functions
fu! menu#SYNC(...) "{
  if len(a:000)<2|return 1|endif
  let orig = a:1
  let dest = a:2

  if !filereadable(orig)|return|endif
  call mkdir(fnamemodify(dest,':h'),'p')
  if writefile(readfile(orig,'b'),dest,'b')|return|endif

  let sep  = repeat('1001',5)
  let file = join(readfile(dest),sep)

  let rgex = ''
  let rgex.= '\('.sep.'\)*'
  let rgex.= '\(!NVPMTEST&&\|<!---.*--->\|" vim:.*\)'
  let rgex.= '\('.sep.'\)*'

  let file = substitute(file,rgex,'','g')

  let file = split(file,sep)

  " remove trailing whitespaces
  for i in range(len(file))
    let file[i] = substitute(file[i],'\s*$','','')
  endfor
  call writefile(file,dest)

endfu "}
fu! menu#MAKE(...) "{

  if len(a:000)<2|return 1|endif
  let list = a:1
  let dest = a:2
  if !filereadable(dest)
    call mkdir(fnamemodify(dest,':h'),'p')
    call writefile(list,dest)
  endif

endfu "}
fu! menu#yesn(...) "{
  return ["yes","no"]
endfu "}
fu! menu#fixd(...) "{
  let root = get(a:000,0,'.')
  let root = [root,s:root][root=='devl']
  let root = [root,s:nvpm][root=='nvpm']
  return root
endfu "}
