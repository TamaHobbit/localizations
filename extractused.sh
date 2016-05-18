# Generate a usedkeys.txt file for switching an old game to using the new localization system
# Globs together all current localization files and extracts the keys that are in at least one language
# $1, parameter 1: The game directory containing the existing localization files
# For example: 
# extractused.sh Assets/Resources > usedkeys.txt
# extractused.sh Assets/SUISSFancyLib/Localizations >> usedkeys.txt

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z "$1" ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo "$1" | sed 's/\/$//'`;

rename.sh $inputFolder

mkdir -p .internals;
rm -f .internals/tmpusedkeys.txt
source langlist.sh
for language in "${ALL_LANGUAGES[@]}"; do
	cut -d'=' -f1 $inputFolder/$language.txt | tr -d ' ' >> .internals/tmpusedkeys.txt
done

sort -u .internals/tmpusedkeys.txt > .internals/usedkeyssorted.txt;
cat .internals/usedkeyssorted.txt
