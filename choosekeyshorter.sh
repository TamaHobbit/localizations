# Exports the shortest line from each language file
# $1, parameter 1: Input folder containing localizations with only one key, but multiple values
# $2, parameter 2: Destination folder to put new localizations
# I used this in CVIS where there were conflicts in the original set:
# First export a conflicted key to a new folder,
# Then run this on it, remove the key from the main database, and re-add

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;
destinationFolder=`echo $2 | sed 's/\/$//'`;

mkdir -p $destinationFolder

source langlist.sh
for lang in "${ALL_LANGUAGES[@]}"; do
	awk '{ print length($0),$0 | "sort -n"}' $inputFolder/$lang.txt | cut -d' ' -f2- | head -n 1 > $destinationFolder/$lang.txt
done
