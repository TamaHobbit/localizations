# Renames all .ini files to .txt
# $1, parameter 1: The folder containing text files to convert
# Example: initotxt.sh iap_notification/

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

find $inputFolder -type f | (while read file; do mv $file `echo $file | sed 's/\.ini/\.txt/'`; done)
