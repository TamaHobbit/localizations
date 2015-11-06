# Generate a usedkeys.txt file for switching an old game to using the new localization system
# Globs together all current localization files and extracts the keys that are in at least one language
# $1, parameter 1: The game directory containing the existing localization files

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

rm -f usedkeys.txt

source langlist.sh
for language in "${ALL_LANGUAGES[@]}"; do
	cut -d'=' -f1 $inputFolder/$language.txt | tr -d ' ' >> usedkeys.txt
done

sort -u usedkeys.txt > tmp.txt;
mv tmp.txt usedkeys.txt
