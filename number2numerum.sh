#!/bin/sh
#
# Shell script that converts number to english numerum.
# 24.10.2008
# Sami Kerola <kerolasa@iki.fi>

POS=0
LAST=$((${#1}-1))
LEN=${#1}

Prefixes() {
    case $1 in
        4)  printf " thousand ";;
        7)  printf " million ";;
        10) printf " billion ";;
        13) printf " trillion ";;
        16) printf " quadrillion ";;
        19) printf " quintillion ";;
    esac
}

Hundreds() {
    OneToNine $1
    printf " hundred "
}

TeenTens() {
    case $1 in 
        1)  printf "eleven";;
        2)  printf "twelve";;
        3)  printf "thirteen";;
        4)  printf "fourteen";;
        5)  printf "fiveteen";;
        6)  printf "sixteen";;
        7)  printf "seventeen";;
        8)  printf "eighteen";;
        9)  printf "nineteen";;
    esac
}

Tens() {
    case $1 in 
        1)  printf "ten";;
        2)  printf "twenty ";;
        3)  printf "thirty";;
        5)  printf "fifty";;
        8)  printf "eighty";;
        0)  ;;
        ?)  OneToNine $1
            printf "ty ";;
    esac
}

LongTens() {
    case $1 in
        2)  printf "twen";;
        3)  printf "thir";;
        5)  printf "fif";;
        8)  printf "eigh";;
        ?)  OneToNine $1;;
    esac
    printf "ty "
}

OneToNine() {
    case $1 in 
        1)  printf "one";;
        2)  printf "two";;
        3)  printf "three";;
        4)  printf "four";;
        5)  printf "five";;
        6)  printf "six";;
        7)  printf "seven";;
        8)  printf "eight";;
        9)  printf "nine";;
    esac
}

if [ $1 -eq 0 ]; then
    echo zero
    exit 0
fi

while [ $POS -le $LAST ]; do
    FSEL=$(($LEN%3))
    case $FSEL in
        1)  FunctionPointer=OneToNine;;
        2)  if [ ${1:$(($POS+1)):1} -eq 0 ]; then
                FunctionPointer=Tens
            elif [ ${1:$(($POS)):1} -eq 1 ]; then
                FunctionPointer=TeenTens
                POS=$(($POS+1))
            else
                FunctionPointer=LongTens
            fi
            ;;
        0)  FunctionPointer=Hundreds;;
    esac

    $FunctionPointer ${1:$POS:1}

    if [ $FSEL -eq 1 -a $POS -ge 0 ]; then
        Prefixes $(($LEN))
    fi

    POS=$(($POS+1))
    LEN=$(($LEN-1))
done

# This will just ad a new line.
echo

# EOF
