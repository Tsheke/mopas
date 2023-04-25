#!/bin/sh

MOOVERS="$1"
MOODIR="$2"
MOOGIT='https://github.com/moodle/moodle.git'
BRANCHE='master'
GITMODFILE="$3"
H5PDIR='mod/hvp'
CURDIR=$(pwd)


if ( [ -z "$GITMODFILE" ] )
 then
  GITMODFILE='gitmodules'
fi

echo "using git sub"

if ( [ -z "$MOOVERS" ] || [ -z "$MOODIR" ] || [ "$MOOVERS" = "-h" ] )
 then
  echo "usage:"
  echo "./moopas.sh <MOOVERS> <MOODIR> [GITMODULES]"
  echo "MOOVERS is a moodle version. i.e. 401 or 'master'"
  echo "MOODIR is the moodle packaging directory"
  echo "GITMODULES is a file of 'gitmodules' format with optionnals mopas fields"
  echo "Ex 1: Run"
  echo "./moopas 401 moodle gitmodMood41"
  echo "to package moodle 401 stable in 'moodle' directory"
  echo "Ex 2: Run"
  echo "./moopas 401 moodle"
  exit 1;
fi


echo "Running script from directory: $CURDIR"
echo "Using gitmodulefile: $GITMODFILE"


if (echo "$MOOVERS"|grep -Ei "^[0-9]+$")
then
   BRANCHE='MOODLE_'"$MOOVERS"'_STABLE'
elif ( [ "$MOOVERS" != "master" ] )
then
  echo "Unkown version: $MOOVERS"
exit 1 
fi
echo "Version: $MOOVERS"
echo "packaging directory: $MOODIR"

# make sure directory doesn't exist and not empty

if( [ -f "$MOODIR" ] || [ -d "$MOODIR" ] && [ -n "$(ls -A "$MOODIR")" ] )
then
 echo "a file/directory "$MOODIR" exists already or/and directory not empty"
 echo "To clone in an existing directory, remove every things:"
 echo "rm -rf $MOODIR/*  $MOODIR/.* "
 echo "rename it or change directory"
 exit 1
fi
# clone moodle core branch
git clone --depth 1 "$MOOGIT" -b "$BRANCHE" "$MOODIR"
#copy gitmodules for plugins

echo "copying .gitmodules file ..."
cp "$GITMODFILE" "$MOODIR/.gitmodules"
#exit 0
# from https://stackoverflow.com/questions/11258737/restore-git-submodules-from-gitmodules

# to initialize submodule not added with 'git submodule add'
cd "$MOODIR"
echo "initializing submodule directories ..." 
set -e

git config -f .gitmodules --get-regexp '^submodule\..*\.path$' |
    while read path_key path
    do
        url_key=$(echo $path_key | sed 's/\.path/.url/')
        url=$(git config -f .gitmodules --get "$url_key")
        skip_key=$(echo $path_key | sed 's/\.path/.skip/')
        skip=$(git config -f .gitmodules --get "$skip_key" || echo)
        if ( [ -z "$skip" ] ) # no skip key. If skip key do not install
          then
          git submodule add $url $path
        fi;
        
    done
    
# To update plugins: 
echo "Updating submodules ..."
 
pwd
git submodule update --init --recursive
pwd

#checkout branch, tags or particular commits

git config -f .gitmodules --get-regexp '^submodule\..*\.path$' |
    while read path_key path
    do
        url_key=$(echo $path_key | sed 's/\.path/.url/')
        url=$(git config -f .gitmodules --get "$url_key")
        #git submodule add $url $path
        #tag
        tag_key=$(echo $path_key | sed 's/\.path/.tag/')
        skip_key=$(echo $path_key | sed 's/\.path/.skip/')
        branch_key=$(echo $path_key | sed 's/\.path/.branch/')
        tag=$(git config -f .gitmodules --get "$tag_key" || git config -f .gitmodules --get "$branch_key" ||echo)
        skip=$(git config -f .gitmodules --get "$skip_key" || echo)
        if( [ ! -z "$tag" ] && [ -z "$skip" ] ) # plugin has tag and no skip field
          then
           cd $path
           git fetch --all --tags
           git checkout $tag
           git submodule update --init --recursive || echo "no submodule path"
           git submodule update --recursive || echo "no submodule path"
           cd -   #go back 
        fi;
        
    done


# check for h5p

if( [ -d "$H5PDIR" ] )
then
 cd "$H5PDIR"
 git submodule update --init --recursive
 cd - # go back
fi
exit 0 
 
