# Print the languages for which the given key is missing
# $1, parameter 1: The input folder containing the main database
# $2, parameter 2: The key to search for

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

source langlist.sh
for language in "${ALL_LANGUAGES[@]}"; do
	grep "^$2=" $inputFolder/$language.txt > tmp.txt
	[ -s tmp.txt ] || echo $language;
done
rm tmp.txt;
