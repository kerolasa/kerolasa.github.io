#!/bin/bash
#
# Shell script that converts number to english numerum.
# 2008-10-24
# Sami Kerola <kerolasa@iki.fi>

SCRIPT_INVOCATION_SHORT_NAME="${0##*/}"
set -e
trap 'echo "$SCRIPT_INVOCATION_SHORT_NAME: exit on error in line $LINENO"; exit 1' ERR
set -u
shopt -s extglob

Prefixes() {
	if [ "$2" -eq 0 ]; then
		return
	fi
	case "$1" in
		4)  printf " thousand ";;
		7)  printf " million ";;
		10) printf " billion ";;
		13) printf " trillion ";;
		16) printf " quadrillion ";;
		19) printf " quintillion ";;
		22) printf " sextillion ";;
		25) printf " septillion ";;
		28) printf " octillion ";;
		31) printf " nonillion ";;
		34) printf " decillion ";;
		37) printf " undecillion ";;
		40) printf " duodecillion ";;
		43) printf " tredecillion ";;
		46) printf " quattuordecillion ";;
		49) printf " quindecillion ";;
		52) printf " sexdecillion ";;
		55) printf " septendecillion ";;
		58) printf " octodecillion ";;
	esac
}

Hundreds() {
	OneToNine "$1" &&
	printf " hundred "
}

TeenTens() {
	case "$1" in
		1)  printf "eleven";;
		2)  printf "twelve";;
		3)  printf "thirteen";;
		4)  printf "fourteen";;
		5)  printf "fiveteen";;
		6)  printf "sixteen";;
		7)  printf "seventeen";;
		8)  printf "eighteen";;
		9)  printf "nineteen";;
		0)  return 1
	esac
	return 0
}

Tens() {
	case "$1" in
		1)  printf "ten";;
		2)  printf "twenty ";;
		3)  printf "thirty";;
		5)  printf "fifty";;
		8)  printf "eighty";;
		0)  ;;
		?)  OneToNine "$1" && printf "ty ";;
	esac
}

LongTens() {
	case "$1" in
		2)  printf "twenty ";;
		3)  printf "thirty ";;
		5)  printf "fifty ";;
		8)  printf "eighty ";;
		?)  OneToNine "$1" && printf "ty ";;
	esac
}

OneToNine() {
	case "$1" in
		1)  printf "one";;
		2)  printf "two";;
		3)  printf "three";;
		4)  printf "four";;
		5)  printf "five";;
		6)  printf "six";;
		7)  printf "seven";;
		8)  printf "eight";;
		9)  printf "nine";;
		0)  return 1
	esac
	return 0
}

rewindPos() {
	case "$1" in
		0)
			thatmuch=1
			ppos=0
			return
			;;
		1)
			thatmuch=2
			ppos=0
			return
			;;
	esac
	ppos=$(("$1" - 2))
}

printOneNumber() {
	case "$1" in
		@(-|)0*(0))
			printf 'zero'
			;;
		@(-|)[0-9]*([0-9]))
			;;
		*)
			echo "$SCRIPT_INVOCATION_SHORT_NAME: $1: is not a number" >&2
			return
			;;
	esac
	POS=0
	LAST="${#1}"
	LEN="${#1}"
	if [ "${1:0:1}" = '-' ]; then
		printf "minus "
		POS=1
		LEN=$((LEN - 1))
	fi
	if [ 61 -lt "$LEN" ]; then
		echo "$1: too large number"
		return
	fi
	fixprefix=0
	thatmuch=3
	ppos=0
	hundredspace=1
	while [ "$POS" -lt "$LAST" ]; do
		FSEL=$((LEN % 3))
		case "$FSEL" in
			1)
				FunctionPointer=OneToNine
				;;
			2)
				if [ "${1:$((POS + 1)):1}" -eq 0 ]; then
					FunctionPointer=Tens
				elif [ "${1:$((POS)):1}" -eq 1 ]; then
					FunctionPointer=TeenTens
					POS=$((POS + 1))
					LEN=$((LEN - 1))
					fixprefix=1
				else
					FunctionPointer=LongTens
				fi
				;;
			0)
				if [ 1 -le "$LEN" ]; then
					FunctionPointer=Hundreds
					hundredspace=0
				else
					FunctionPointer=OneToNine
				fi
				;;
		esac
		$FunctionPointer "${1:$POS:1}" || true
		if [ "$FSEL" -eq 1 ] || [ "$fixprefix" -eq 1 ]; then
			rewindPos "$POS" "$LEN"
			if [ "$hundredspace" -eq 1 ]; then
				printf " "
			fi
			Prefixes "$LEN" "${1:$ppos:$thatmuch}"
			fixprefix=0
			thatmuch=3
			hundredspace=1
		fi
		POS="$((POS + 1))"
		LEN="$((LEN - 1))"
	done
	printf "\n"
}

if [ $# -eq 0 ]; then
	while read -r n; do
		printOneNumber "$n"
	done
else
	for n in "$@"; do
		printOneNumber "$n"
	done
fi

exit 0
# EOF
