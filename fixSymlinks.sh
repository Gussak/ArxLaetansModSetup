#!/bin/bash

# Copyright 2023 Gussak<https://github.com/Gussak>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# find -type l -exec readlink '{}' \; |egrep "$USER|home|^/" -i #check if symlinks are relative

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
