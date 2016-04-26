# Choose the shortest translation for every duplicate key in every language
# $1, parameter 1: The input folder containing the main database
# Uses this method; for each conflicted key, first export just that key to a new folder,
# Then run chooseshorter.sh on it, remove the key from the main database, and re-add from the new folder

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

mkdir .internals -p;
mkdir .internals/shorter -p;

checkunique.sh all_translations/
# Now we have .internals/dup/$language.txt with the duplicate keys

source langlist.sh
for language in "${ALL_LANGUAGES[@]}"; do
	cat .internals/dup/$language.txt | (while read key; do
		# for each key in the duplicates list for this language
		
		echo "Resolving $key...";
		
		# From export.sh; generate a regex for the key so we don't also catch accidental mentions of the key elsewhere
		regex=`echo $key | sed 's/^/\^/' | sed 's/$/=/'`;
		grep $regex $inputFolder/$language.txt | # This pipe contains all lines with the key; the conflict set
		awk '{ print length($0),$0 | "sort -n"}' | cut -d' ' -f2- | head -n 1 > .internals/shorter/$language.txt
		
		# From removekey.sh
		sed "/^$key=/d" $inputFolder/$language.txt > tmp.txt
		mv tmp.txt $inputFolder/$language.txt
		merge_lang.sh .internals/shorter/ $language $inputFolder
		
	done)
done
