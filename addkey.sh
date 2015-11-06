# Add new keys to be translated and used in game. Type each new key on a new line, followed up by Cntrl^D to signify end-of-file.
# You can also pipe in a text file with the keys to be added.
# $1, parameter 1: The current usedkeys.txt file, that should normally be in the root of your project

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

cat >> $1;
sort -i $1 -o $1

echo "Run \`export.sh localizationsRepo/all_translations myTranslationResources $1\` to get the new keys.";