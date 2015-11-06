# Makes sure there is no whitespace around the "=" character anywhere in the given file
# $1, parameter 1: The file to normalise

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

sed "s/ *=/=/" $1 | sed "s/= */=/" > tmp.txt;
mv tmp.txt $1;
