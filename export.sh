# Export from one main database into a game-specific one, importing only those keys listed as used in usedkeys.txt
# $1, parameter 1: The input folder containing the main database
# $2, parameter 2: The destination folder to export to (will start by removing existing localizations)
# $3, parameter 3: A text file containing exactly the keys to export, each on a seperate line

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;
destinationFolder=`echo $2 | sed 's/\/$//'`;

source util.sh
source langlist.sh

# turn lines containing e.g. "gold" into "^gold=", so that only exact matches are exported
sed 's/^/\^/' $3 | sed 's/$/=/' > .internals/keyregexes.txt

# make destination if it doesn't exist
mkdir -p $destinationFolder
# remove all files from it
for language in "${ALL_LANGUAGES[@]}"; do
	rm -f $destinationFolder/$language.txt
	grep -f .internals/keyregexes.txt $inputFolder/$language.txt > $destinationFolder/$language.txt
done

#clean up
normalizespaces.sh $destinationFolder
sort.sh $destinationFolder

echo "Now run status.sh $destinationFolder $3 to check the results."
