# Subtract one usedkeys.txt file from another, to remove many keys at once.
# $1, parameter 1: The current usedkeys.txt file, that should normally be in the root of your project
# $2, parameter 2: The keys.txt file with undesired keys, to be removed from usedkeys.txt

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

mkdir -p .internals/;
sed 's/^/\^/' $2 | sed 's/$/\$/' > .internals/removekeyregexes.txt;
grep -v -f .internals/removekeyregexes.txt $1 > .internals/tmpnewkeys.txt;
mv .internals/tmpnewkeys.txt $1;
