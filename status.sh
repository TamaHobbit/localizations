# Prints the status, checking for untranslated keys in English.txt and conflicted keys in English.txt
# $1, parameter 1: The destination folder containing the existing translations to check
# $2, parameter 2: The usedkeys.txt file to check against. If you don't have one, use extractused.sh to make one.
# Flags:
# -s	sort any files not already sorted
# Example:
# status.sh iap_keys/ usedkeys.txt
# status.sh iap_keys/ usedkeys.txt
# Or perhaps:
# status.sh ../../cig2/Assets/Resources/ ../../cig2/usedkeys.txt

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

if [ -z $2 ]; then
	echo "Parameter 2, usedkeys.txt, is mandatory!";
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

source langlist.sh
source util.sh

# If the given folder has not yet been rename.sh'ed, rename.sh it and continue
test -e $inputFolder/English.txt
if [ $? -eq 1 ]; then # unable to find English.txt in given folder
	ENGLISH_DIR=($inputFolder/"en/");
	test -e $ENGLISH_DIR;
	if [ $? -eq 0 ]; then
		echo "";
		rename.sh $inputFolder/
	fi
fi

echo "-------Checking formatting---------------";
mkdir .internals -p # Make if not present; because internals/ is .gitignore'd, it will not be present when you checkout
mkdir .internals/sortdiff -p
UNSORTED_FILES=0;
for language in "${ALL_LANGUAGES[@]}"; do
	test -e $inputFolder/$language.txt;
	if [ $? -gt 0 ]; then
		continue; # for sortedness, it is not an error to be missing some files, just ignore them
	fi

	sort $inputFolder/$language.txt > .internals/$language.txt
	diff $inputFolder/$language.txt .internals/$language.txt > .internals/sortdiff/$language.txt

	diff_lines .internals/sortdiff/$language.txt;
	SORTDIFF_LINES=$?; # store return value of function, since any command (including mv or cp) will write their own return value to the same variable

	if [ $SORTDIFF_LINES -gt 0 ]; then
		UNSORTED_FILES=1;
		printf "%19s is not sorted, %3i lines differ\n" $language $SORTDIFF_LINES;
	fi
	
	rm .internals/$language.txt;
	rm .internals/sortdiff/$language.txt
done

if [ $UNSORTED_FILES -gt 0 ]; then
	echo "Run \`sort.sh $1\` to fix the sorting. Always commit this seperately to any other changes.";
fi

# Check if normalizespaces.sh needs to be run
rm -f .internals/normalizecheckfile.txt
for language in "${ALL_LANGUAGES[@]}"; do
	grep " =\|= " $inputFolder/$language.txt >> .internals/normalizecheckfile.txt;
done
abnormalLines=`wc -l .internals/normalizecheckfile.txt | cut -d' ' -f1`;
# cut -d' ' -f1 is to get the number before the space, which is the number of lines in the file
if [[ $abnormalLines -gt 0 ]]; then
	echo "You need to run \`normalizespaces.sh $1\` to ensure that there are no spaces around the \"=\" character.";
fi
rm -f .internals/normalizecheckfile.txt

echo "-------Checking keys present-------------";

keysmatch.sh $inputFolder/ $2 -s
keysMissing=$?;

if [ $keysMissing -gt 0 ]; then
	echo "Run \`keysmatch.sh $1 $2\` for more information about which keys are missing in each file.";
fi

echo "-------Checking for conflicted keys------";

checkunique.sh $inputFolder/ -s
conflictedKeys=$?;

if [ $conflictedKeys -gt 0 ]; then
	echo "Run \`checkunique.sh $1\` for more information about which keys are duplicated in each file.";
fi

echo "-------Checking formatstrings------------";

formatstrings.sh $inputFolder/ -s
formatstringError=$?;

if [ $formatstringError -gt 0 ]; then
	echo "Run \`formatstrings.sh $1\` for more information about the formatstring errors.";
fi

fatalErrors=$(($keysMissing + $conflictedKeys + $formatstringError));

if [ $fatalErrors -eq 0 ]; then
	echo "No fatal errors encountered.";
	exit 0;
else
	echo "Fix the errors and try again.";
	exit 1;
fi
