#!/bin/bash

# get script filename without extension
SCRIPT_NAME=$(basename "$0" | cut -d. -f1)

# check if PID file exists
if [ -f /tmp/"$SCRIPT_NAME".pid ]; then
	echo "PID file exists"
	exit 1
else
	# save PID 
	echo $$ > /tmp/"$SCRIPT_NAME".pid
fi

# remove PID and /tmp $SCRIPT_NAME.png on exit
trap 'rm -f /tmp/$SCRIPT_NAME.pid /tmp/$SCRIPT_NAME.png /tmp/$SCRIPT_NAME.compare.png' EXIT

# if --help or -h is given, print help
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	echo "Usage:"
	echo "$0 -h, --help: Print this help"
	echo "$0 -x: debug mode on"
	echo "$0 3: Set delay to 2 seconds"
	echo "$0 3 0.15: Set delay to 2 seconds and compression to 15%"
	echo
	echo Thank you for using screemshotter.sh by @shirobachi
	exit 0
fi

# set -x if flag is set
if [ "$1" = "-x" ] || [ "$3" == "-x" ]; then
	set -x
else
	# check if is 1 empty
	if [ "$1" = "" ]; then
		border=0.11
	else
		border=$1
	fi

	# check if is 2 argument
	if [ "$2" = "" ]; then
		sleeper=1
	else
		sleeper=$2
	fi

fi

# let show notifcation from bg
export DISPLAY=:0.0

# check if magick installed
if [ ! $(which magick) ]; then
	# Get place to save magick
	path=$(echo "$PATH" | tr ":" "\n" | head -1)
	
	# Download macick from url
	link="https://download.imagemagick.org/ImageMagick/download/binaries/magick"
	notify-send "Downloading magick" "Please wait..."
	wget "$link" -O "$path"/magick
	notify-send "Downloading magick" "Done"
	chmod +x "$path"/magick
fi

# --------------------------------------------------

## make variable with current date
date=$(date +%Y-%m-%d_%H-%M-%S)

mkdir -p "$HOME/Downloads/$date/logs"
mkdir -p "$HOME/Downloads/$date/screenshots"

while true; do

	# kill notifcation during screenshot
	killall -q dunst

	# name of made ss
	ssFilename=$(date +%Y-%m-%d_%H-%M-%S-%3N)
	ssPath="$HOME/Downloads/$date/screenshots/$ssFilename.png"

	# make full screen screenshot
	magick import -window root $ssPath
	sleep .5

	# check if have ss to compare
	if [ -f "/tmp/$SCRIPT_NAME.png" ]; then
		# compare ss
		diff=$(magick compare -metric RMSE -subimage-search "$ssPath" "/tmp/$SCRIPT_NAME.png" "/tmp/$SCRIPT_NAME.compare.png" 2>&1)

		par1=$(echo $diff | cut -d' ' -f1)
		par2=$(echo $diff | cut -d'(' -f2 | cut -d')' -f1)
		par3=$(echo $diff | cut -d' ' -f4)

		# if diff is more than 0.11
		if [ $(echo "$par2 > $border" | bc) -eq 1 ]; then
			same=true
		else
			same=false
		fi

		# cp and overwrite ss
		cp "$ssPath" "/tmp/$SCRIPT_NAME.png"

		mv "/tmp/$SCRIPT_NAME.compare.png" $HOME/Downloads/$date/logs/$ssFilename:$same:$par1:$par2:$par3.png
	else # if it's very 1st ss
		# mv file to compare destination
		cp "$ssPath" /tmp/$SCRIPT_NAME.png
	fi

	# check if pid file exists
	if [ ! -f /tmp/"$SCRIPT_NAME".pid ]; then
		# check if pid is still running

		break 
	fi

	sleep $sleeper
done

# make dir for different screenshots
mkdir $HOME/Downloads/$date/tar

# mv the very first ss
latest=$(ls -tp $HOME/Downloads/$date/screenshots | grep -v / | tail -1)
cp $HOME/Downloads/$date/screenshots/$latest $HOME/Downloads/$date/tar

# mv rest different sses
ls "$HOME/Downloads/$date/logs" | grep true | cut -d : -f1 | xargs -I {} cp "$HOME/Downloads/$date/screenshots/{}.png" "$HOME/Downloads/$date/tar"

# make tar
cd "$HOME/Downloads/$date/tar" || exit
tar -czf "$HOME/Downloads/$date/$date.tar.gz" ./*
cd - || exit