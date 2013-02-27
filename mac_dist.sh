#!/bin/sh

# You cannot use the set command with a backquoted getopt directly,
# since the exit code from getopt would be shadowed by those of set,
# which is zero by definition.
while getopts o:p: opt
do
    case "$opt"
    in
    (o)
        APP=$OPTARG
        CONTENTS=$OPTARG/HyperDex.app/Contents
        MACOS=$OPTARG/HyperDex.app/Contents/MacOS
        RESOURCES=$OPTARG/HyperDex.app/Contents/Resources
        ;;
    (p)
        PREFIX=$OPTARG
        ;;
    (*)
        echo "Usage: ./mac_dist.sh -o <appdir> -p <prefix>"
        exit
        ;;
    esac
done

mkdir -p $RESOURCES
mkdir -p $MACOS

cp -r $PREFIX/* $MACOS/
cd $MACOS

stop=0
while (( $stop == 0 ))
do
echo ""
echo ""
echo ""
stop=1
B=`find . -type f -perm -100` 
for bin in $B
do
    echo BIN $bin
    otool -L $bin | sed -n '2,$ s/^[^\\]\(.*\) (.*)$/\1/g p' | while read lib
    do
        if [[ $lib == /usr/lib/* ]]; then
            echo "Skipping $lib: system file"
        else
            echo LIB $lib
            a=`basename $bin`
            b=`basename $lib`
            if find . -name "$bname"; then
                echo "Skipping $lib: already exists"
            else
                cp $lib ./lib/
                stop=0
            fi

            if [[ $lib == $PREFIX/libexec/* ]]; then
                install_name_tool -change $lib @executable_path/../libexec/$b $bin
                install_name_tool -id @executable_path/../libexec/$b $bin
            else
                install_name_tool -change $lib @executable_path/../lib/$b $bin
                install_name_tool -id @executable_path/../lib/$b $bin
            fi
        fi
    done
done
done

echo ""
echo ""
echo "CHECKING INSTALLED BINARIES"
B=`find . -type f -perm -100`
for bin in $B
do
    echo BIN $bin
    otool -L $bin | sed -n '2,$ s/^[^\\]\(.*\) (.*)$/\1/g p' | while read lib
    do
        if [[ $lib != /usr/lib/* && $lib != @executable_path/* ]]; then
            echo $lib
        fi
    done
done
