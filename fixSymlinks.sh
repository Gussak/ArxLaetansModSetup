#!/bin/bash

function FUNCfixLnk() { 
  local lstrFl="$1"; 
  echo
  echo ">>>>>>>>>>>>>> $lstrFl";
  local lstrFlBN="$(basename "$lstrFl")";
  local lstrLnk="`readlink "$lstrFl"`"; 
  declare -p lstrFl lstrFlBN lstrLnk; 
  pwd
  cd "$(dirname "$lstrFl")"; 
  pwd
  ls -ld "$lstrFlBN" "$lstrLnk"&&:
  # chk invalid
  if [[ "$lstrLnk" =~ .*${USER}.* ]];then echoc -p "invalid symlink";echoc -w;return 0;fi
  if [[ "$lstrLnk" =~ ^/.* ]];then echoc -p "invalid absolute symlink";echoc -w;return 0;fi
  
  # chk skip
  if [[ "$lstrFl" =~ ^[.]/ArxLaetansMod/.* ]];then echoc --info "SKIP: helper folder above";return 0;fi
  #if [[ -d "$lstrLnk" ]];then echoc --info "SKIP: dir above";return 0;fi
  if ! [[ "$lstrLnk" =~ .*ArxLaetansMod[.]github.* ]];then echoc --info "SKIP: probably not wrong '$lstrFl'";return 0;fi
  
  local lstrTgtFix="$(echo "$lstrLnk" |sed -r -e 's@[.][.]/[.][.]/ArxLaetansMod[.]github/ArxLaetansMod[.][^/]*/@@')";
  declare -p lstrTgtFix; 
  if ls -ld "$lstrTgtFix";then
    if cmp "$lstrTgtFix" "$lstrFlBN";then
      if cmp "$lstrTgtFix" "$lstrLnk";then
        ln -vsfT "$lstrTgtFix" "$lstrFlBN"
        ls --color=always -ld "$lstrFlBN"
        echoc --info SUCCESS
        return 0
      fi
    fi
  fi
  echoc -p "FAIL above"
  echoc -w
};export -f FUNCfixLnk;
find -type l -exec bash -c "FUNCfixLnk '{}'" \;
