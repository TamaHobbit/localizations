# Checks if keys match in all languages; expects our format, i.e. 1 folder with 18 files such as English.txt and Danish.txt
# (no output means everything is fine)
# $1, parameter 1: The destination folder containing the existing translations to check
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

summary=0;
if [ ! -z $2 ]; then
	if [ $2 == "-s" ]; then
		summary=1;
	else
		echo "Unknown parameter: $2";
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
mkdir .internals/keys/diff-english -p
mkdir .internals/keys/untranslated -p
mkdir .internals/keys/dirty-add -p
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
	if [ "$language" == "English" ]; then
		continue;
	fi

	diff .internals/keys/English.txt .internals/keys/$language.txt > .internals/keys/diff-english/$language.txt
	diff_lines .internals/keys/diff-english/$language.txt;
	SORTDIFF_LINES=$?;
	if [ $SORTDIFF_LINES -gt 0 ]; then
		keysMissing=1;
		if [ $summary -eq 1 ]; then
			printf "%19s keys do not match: %3i differences\n" $language $SORTDIFF_LINES;
			rm .internals/keys/diff-english/$language.txt;
			rm .internals/keys/$language.txt;
		else
			if [ $summary -eq 0 ]; then
				# TODO; could probably be simplified with e.g. `comm -23 file1 file2 > file3`, which gives all entries in file1 that are not in file2
				grep "^<" .internals/keys/diff-english/$language.txt | cut -d' ' -f2 > .internals/keys/untranslated/$language.txt
				cat .internals/keys/untranslated/$language.txt >> .internals/keys/untranslated/all.txt
				grep "^>" .internals/keys/diff-english/$language.txt | cut -d' ' -f2 > .internals/keys/dirty-add/$language.txt
			fi
		fi
	fi
done

if [ $summary -eq 1 ]; then
	rm .internals/keys/English.txt;
fi

if [ $keysMissing -gt 0 ]; then
	# print all the diffs to the console
	if [ $summary -eq 0 ]; then
		# first keys that are untranslated in all languages as a whole, removing these from individual languages
		sort .internals/keys/untranslated/all.txt | uniq -c | sort -n -r > .internals/untranslated_languagecount.txt;
		awk '{ if( $1 == 17 ){ print $2; } else { exit; } }' .internals/untranslated_languagecount.txt | sort > .internals/missing_in_all_languages.txt
		
		echo "These keys are missing in all languages:";
		cat .internals/missing_in_all_languages.txt
		
		for language in "${ALL_LANGUAGES[@]}"; do
			if [ "$language" == "English" ]; then
				continue;
			fi
	
			echo "Present in English, but not in $language:";
			diff .internals/keys/untranslated/$language.txt .internals/missing_in_all_languages.txt | grep "^<" | cut -d" " -f2
			echo "Present in $language but not in English:";
			cat .internals/keys/dirty-add/$language.txt
		done
		
		echo "";
		echo "For more information, you can examine the tmp files that have just been made:"
		echo "Examine .internals/missing_in_all_languages.txt to see the keys that are only present in English.txt (pending translations, sent to translators)";
		echo "Examine .internals/keys/untranslated/[languagename].txt to see all keys for that language that are untranslated, including those printed above as missing in all languages.";
		echo "Examine .internals/keys/dirty-add/[languagename].txt to find keys that were added in some language other than English. (these are a big problem if present, as the source is not defined, probably you need to merge a different database with addtranslations.sh form a database that does contain these keys)";
		echo "Examine .internals/untranslated_languagecount.txt to see for each key how many languages are missing that key.";
	fi
fi

exit $keysMissing;
