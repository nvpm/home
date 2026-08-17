let s:tabs = ''
let s:root = ''

fu! meta#sync(...) "{

  call meta#tabs()

  let msg  = s:tabs..'Sync files? [yes/no] '
  let user = input(msg,'yes','customlist,meta#yesn')
  if empty(user)||user==?'no'|return 1|else
    echo "\n"
    let list = meta#plug()
    call filter(list,'v:val!="nvpm"')
    call meta#copy(list,'nvpm')
    call meta#SYNC('nvpm.md','../nvpm/README.md',1)
    call meta#SYNC('LICENSE','../nvpm')
  endif

endfu "}
fu! meta#save(...) "{

  if empty(s:root)
    let root = get(a:,1,'')
    if empty(root)
      let root = './'
    else
      let root = '../nvpm'
    endif
  else
    let root = s:root
  endif
  call meta#tabs()
  let status = system('git -C '.root.' status --porcelain')
  if empty(status)
    echon s:tabs
    echohl Visual
    echon 'Clean Working Directory at ('.root.'). Aborting commit...'
    echohl None
    return 0
  else
    let status = split(status,"\n")
    call map(status,'trim(v:val)')
    let status = s:tabs.. join(status,"\n".s:tabs)
    echon s:tabs
    echohl Error
    echon 'Modified content at ('.root.')'
    echohl None
    echo status
  endif

  echohl Title
  echo s:tabs..'type commit message'
  let msg = input(s:tabs)
  echohl None
  if empty(msg)|return 1|endif
  echo system('git -C '.root.' add .')
  echo "\n"
  let sys = system('git -C '.root.' commit -m "'.msg.'"')
  let sys = split(sys,"\n")
  call map(sys,'trim(v:val)')
  let sys = s:tabs.. join(sys,"\n".s:tabs)
  ec sys

endfu "}
fu! meta#push(...) "{

  if !exists('g:NVPMCRYP')
    echo 'Define g:NVPMCRYP to the gpg gitcredential file path'
    return 1
  endif
  let root = get(a:,1,'home')
  if empty(root)
    let s:root = './'
  else
    let s:root = '../nvpm'
  endif
  let repo = ['home','nvpm'][s:root=='../nvpm']
  echo "\n"

  if meta#save()|return 1|endif

  call meta#tabs()
  let git = 'git -C '.s:root.' '

  " retrive token {

    let tfile = fnamemodify(g:NVPMCRYP,':p:r')
    if filereadable(tfile)|call delete(tfile)|endif
    echo "\n"
    echohl Title
    echo s:tabs..'Pushing to https://github.com/nvpm/'..repo
    let password = inputsecret(s:tabs..'type the passphrase: ')
    if empty(password)|return 1|endif
    let command = 'gpg -q --no-symkey-cache --batch --passphrase '
    let command.= password..' '..g:NVPMCRYP
    call system(command)
    if v:shell_error
      echon "\n"
      echon s:tabs
      echohl Error
      echon 'Wrong passphrase'
      echohl None
      return 1
    endif

  " }
  " push w/ token {

    if filereadable(tfile)
      let sys = system(git..'push --force origin --mirror')
      call delete(tfile)
      let sys = split(sys,"\n")
      call map(sys,'trim(v:val)')
      let sys = s:tabs.. join(sys,"\n".s:tabs)
      if v:shell_error
        echo  "\n"
        echohl WarningMsg
        echon sys
        echohl None
        return 1
      else
        echo  "\n"
        echohl Normal
        echo sys
        echohl None
      endif
    endif

  " }

  let s:root = ''

endfu "}
fu! meta#make(...) "{

  echo repeat('-',&columns)
  let plug = input('New plugin name: ')
  if empty(plug)|return 1|endif

  " create files {

    let plug = tolower(plug)
    let PLUG = toupper(plug)

    let autoload = [
    \'" auto/'..plug,
    \'',
    \'if !NVPMTEST&&exists("_'..PLUG..'AUTO_")|finish|endif',
    \'let _'..PLUG..'AUTO_ = 1',
    \'',
    \'',
    \'fu! '.plug.'#'.plug.'(...) "'..repeat(' ',59)..'{',
    \'endfu "}',
    \'',
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

    call meta#MAKE(autoload,'nvim/auto/'..plug..'.vim')
    call meta#MAKE(plugin  ,'nvim/plug/'..plug..'.vim')

  "}

endfu "}

" Helping functions
fu! meta#tabs(...) "{

  if exists('g:zoom.size.l')
    let s:tabs = repeat(' ',g:zoom.size.l)
  endif

endfu "}
fu! meta#copy(...) "{

  let list = a:1
  let dest = a:2
  for plug in list
    call meta#SYNC('autoload/'.plug.'.vim' , '../'.dest)
    call meta#SYNC('plugin/'  .plug.'.vim' , '../'.dest)
    call meta#SYNC('syntax/'  .plug.'.vim' , '../'.dest)
    call meta#SYNC('doc/'     .plug.'.txt' , '../'.dest)
  endfor

endfu "}
fu! meta#SYNC(...) "{

  let orig = a:1
  let dest = a:2
  if !exists('a:3')
    let dest.= '/'..orig
  endif
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
fu! meta#MAKE(...) "{

  if len(a:000)<2|return 1|endif
  let list = a:1
  let dest = a:2
  if !filereadable(dest)
    call mkdir(fnamemodify(dest,':h'),'p')
    call writefile(list,dest)
  endif

endfu "}
fu! meta#yesn(...) "{
  return ["yes","no"]
endfu "}
fu! meta#plug(...) "{
  let list = readdir('autoload')
  call map(list,'fnamemodify(v:val,":r")')
  call add(list,'nvpm')
  return list
endfu "}
