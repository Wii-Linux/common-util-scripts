#!/bin/bash

DIALOG_COMMON="--no-mouse"
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

BACKTITLE=""

# XXX: sometimes COLUMNS isn't set, idk why
# grab it from tput as a fallback.
if [ "$COLUMNS" = "" ] || [ "$COLUMNS" = "0" ]; then
	COLUMNS="$(tput cols)"
fi

format_top_text() {
	text_len=$((${#left_text} + ${#right_text}))
	# dialog has 2 blank chars on the left and right
	padding_length=$((COLUMNS - $text_len - 2))
	padding=$(printf "%${padding_length}s")

	BACKTITLE="$left_text$padding$right_text"
}

format_top_text
# init done, set up some functions

# menu "title" "OK" "Cancel" "Select an option:" 1 "opt1" 2 "opt2" 3 "opt3"
menu() {
	num_opt=$(( ($# - 4) / 2 ))
	exec 3>&1
	selection=$(dialog $DIALOG_COMMON \
		--backtitle "$BACKTITLE" \
		--title "$1" \
		--clear \
		--ok-label "$2" \
		--cancel-label "$3" \
		--menu "$4" "$HEIGHT" "$WIDTH" "$num_opt" \
		"${@:5}" 2>&1 1>&3)
	ret=$?
	exec 3>&-
	case $ret in
		$DIALOG_CANCEL|$DIALOG_ESC)
			clear
			return 255
			;;
	esac
	return $selection
}

yesno() {
	dialog $DIALOG_COMMON \
		--backtitle "$BACKTITLE" \
		--title "$1" \
		--clear \
		--yesno "$2" \
		"$3" "$4" # height, width -- 0, 0 is ugly.
	ret=$?
	case $ret in
		$DIALOG_CANCEL|$DIALOG_ESC|1)
			clear
			return 1
			;;
		0) return 0;;
	esac
	return 255
}

info() {
	dialog $DIALOG_COMMON \
		--backtitle "$BACKTITLE" \
		--title "$1" \
		--msgbox "$2" \
		"$3" "$4" # height, width -- 0, 0 is ugly.
}

unimplemented() {
	info "Sorry!" "This feature isn't implemented yet.\nMake sure your system is up to date (see the ArchPOWER settings menu)" 7 50
}
