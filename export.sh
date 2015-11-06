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

LOCALIZATIONS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
WORKING_DIR=`pwd`;
cd $LOCALIZATIONS_DIR;
mkdir -p $WORKING_DIR/.internals;
git fetch;
git status | sed -n 's/HEAD detached/Warning: Localizations repository is on a detached head (you should check out master)/p' > $WORKING_DIR/.internals/gitstatusdiff.txt;
git status | grep "Changes not staged for commit" >> $WORKING_DIR/.internals/gitstatusdiff.txt;
git log HEAD..origin/master >> $WORKING_DIR/.internals/gitstatusdiff.txt;
GITSTATUS_LINES=`wc -l $WORKING_DIR/.internals/gitstatusdiff.txt | tr -s ' ' | cut -d' ' -f1`;
if [[ $GITSTATUS_LINES -gt 0 ]]; then
	echo "Your git status in the localizations repository, located at $LOCALIZATIONS_DIR is behind / dirty / detached."
	echo "It should be on branch master and up-to-date with origin/master.";
	echo "See .internals/gitstatusdiff.txt for exactly what the problems are.";
else
	rm -f $WORKING_DIR/.internals/gitstatusdiff.txt;
fi
cd $WORKING_DIR;

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
	rm $destinationFolder/$language.txt
	grep -f .internals/keyregexes.txt $inputFolder/$language.txt > $destinationFolder/$language.txt
done

#clean up
rm .internals/keyregexes.txt
normalizespaces.sh $destinationFolder
sort.sh $destinationFolder

mkdir -p .internals/export/

keysMissing=0
for language in "${ALL_LANGUAGES[@]}"; do
	cat $destinationFolder/$language.txt | cut -d'=' -f1 > .internals/export/keys-$language.txt
	diff $3 .internals/export/keys-$language.txt > .internals/export/keys-diff-$language.txt
	diff_lines .internals/export/keys-diff-$language.txt;
	SORTDIFF_LINES=$?;
	if [ $SORTDIFF_LINES -gt 0 ]; then
		keysMissing=1;
		printf "%19s keys do not match: %3i differences\n" $language $SORTDIFF_LINES;
		# cat .internals/export/keys-diff-$language.txt
	fi
done

if [ $keysMissing -gt 0 ]; then
	echo "--------------------------------";
	echo "Some keys were missing in $1";
	echo "Run keysmatch.sh $2 for details";
	echo ".internals/export/keys-[languagename].txt contains the keys included in each language.";
	echo ".internals/export/keys-diff-[languagename].txt contains the difference in keys between that language and English.";
fi
