# Checks for duplicate keys in localization file
# Returns the number of keys that appear more than once
# Writes duplicate keys to e.g. .internals/dup/French.txt
# $1, parameter 1: The file to check

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

cat $1 | cut -d'=' -f1 | sed -e 's/[ \t]*$//' | sort | uniq -d
# cut grabs field before =; sed removes trailing whitespace; sort and uniq output just the duplicate lines
