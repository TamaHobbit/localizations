# Checks if keys match in all languages; expects our format, i.e. 1 folder with 18 files such as English.txt and Danish.txt
# (no output means everything is fine)
# $1, parameter 1: The destination folder containing the existing translations to check
# $2, parameter 2: The usedkeys.txt file to match each language's localizations against
# Flags:
# -s summary; only print the number of differing keys for each language compared to English.txt
# Examples:
# keysmatch.sh iap_keys/
# keysmatch.sh ../../cig2/Assets/Resources/

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

# Remove windows line endings if present in usedkeys.txt, since comm -3 will otherwise complain every key is missing
sed -e s/"^M"//g $2 -i

summary=0;
if [ ! -z $3 ]; then
	if [ $3 == "-s" ]; then
		summary=1;
	else
		echo "Unknown parameter: $3";
		exit 1;
	fi
fi

source langlist.sh
source util.sh

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

rm -rf .internals
mkdir .internals

keysMissing=0;
mkdir .internals/keys -p
mkdir .internals/keys/untranslated -p
for language in "${ALL_LANGUAGES[@]}"; do
	test -e $inputFolder/$language.txt;
	if [ $? -eq 0 ]; then
		sort $inputFolder/$language.txt | cut -d'=' -f1 | sed -e 's/[ \t]*$//' | sort > .internals/keys/$language.txt # cut grabs field before =; sed removes trailing whitespace
	else
		echo $language "is missing. Maybe you have yet to rename.sh these translation files?";
	fi
done

# The append statement in the for-loop below assumes an empty or non-existant file, so first remove all.txt
rm -f .internals/keys/untranslated/all.txt

for language in "${ALL_LANGUAGES[@]}"; do
	comm -3 $2 .internals/keys/$language.txt > .internals/keys/untranslated/$language.txt
	SORTDIFF_LINES=`wc -l .internals/keys/untranslated/$language.txt | cut -d' ' -f1`

	if [ $SORTDIFF_LINES -gt 0 ]; then
		keysMissing=1;
		cat .internals/keys/untranslated/$language.txt >> .internals/keys/untranslated/all.txt
		
		printf "%19s keys do not match: %3i differences\n" $language $SORTDIFF_LINES;
		if [ $summary -eq 0 ]; then
			cat .internals/keys/untranslated/$language.txt
		fi
	fi
done

if [ $keysMissing -gt 0 ]; then	
	# collect keys that are untranslated in any languages, sorting by number of missing languages
	sort .internals/keys/untranslated/all.txt | uniq -c | sort -n -r > .internals/untranslated_languagecount.txt;
	# and get from that the keys untranslated in all languages
	awk '{ if( $1 == $NR_LANGUAGES ){ print $2; } else { exit; } }' .internals/untranslated_languagecount.txt | sort > .internals/missing_in_all_languages.txt
	
	if [ $summary -eq 0 ]; then
		# explain the format used above
		echo "";
		echo "In the list above, below each language with non-matching keys with usedkeys.txt is a list of output from: comm -3 usedkeys.txt languageFile.txt";
		echo "Keys in the first column (immediately at the start of the line), are present in usedkeys.txt but not in that language's localizations.";
		echo "The second column (all lines starting with whitespace) lists dirty changes, present in that language but not specified in usedkeys.txt";
	
		# mention relevant files to the console
		echo "For more information, you can examine the tmp files that have just been made:"
		echo "Examine .internals/missing_in_all_languages.txt to see the keys that are only present in English.txt (pending translations, sent to translators)";
		echo "Examine .internals/keys/untranslated/[languagename].txt to see all keys for that language that are untranslated, including those printed above as missing in all languages.";
		echo "Examine .internals/untranslated_languagecount.txt to see for each key how many languages are missing that key.";
	fi
fi

exit $keysMissing;
