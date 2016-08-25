# Renames all folders with spaces in them
# $1, parameter 1: The directory to apply this to; all subfolders with spaces will be renamed. If this directory itself contains spaces, it will remove those spaces as well and your result will be in there.

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z "$1" ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

( cd $1
	ls | (while read name; do name="$(echo $name | sed 's/\/$//')"; safename=`echo $name | sed 's/ /_/g'`; mv "$name" $safename; done)
	find -type f | (while read name; do name="$(echo $name | sed 's/\/$//')"; safename=`echo $name | sed 's/ /_/g'`; mv "$name" $safename; done)
)
