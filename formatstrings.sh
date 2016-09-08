# Checks that for all languages, the formatstrings in the values match, so that no language-specific crash can occur in a string.Format() call.
# (no output means everything is fine)
# $1, parameter 1: The destination folder containing the existing translations to check
# Flags:
# -s summary; only print the number of differing formatstrings for each language compared to English.txt
# Example:
# formatstrings.sh new_translations_received/
# formatstrings.sh ../../cig2/Assets/Resources/

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

mkdir -p .internals/formatstrings
for language in "${ALL_LANGUAGES[@]}"; do
	# First grep prints all lines with any formatstrings in them;
	# second grep prints only the key, with the formatstring {0} symbols on lines following it
	grep "{[0-9][0-9]*}" $inputFolder/$language.txt | grep -o "{[0-9][0-9]*}\|.*=" | 
		awk 'BEGIN { 
				COUNT = -1; 
			} 
			/{[0-9][0-9]*}/ {
				NEWCOUNT = int(substr($0, 2, length($0)-2)); 
				if( NEWCOUNT > COUNT )
					COUNT = NEWCOUNT;
			} 
			$0 !~ /{[0-9][0-9]*}/ { 
				if( NR > 1 ) 
					print PREVIOUS,"Max:",COUNT;
				PREVIOUS=$0;
			}
			END { 
				print PREVIOUS,"Max:",COUNT; 
			}' > .internals/formatstrings/$language.txt;
done

# now .internals/formatstrings contains for each language a file defining the formatstrings by key; these files should be identical
# Note there is a lot of code duplication with keysmatch.sh since that also creates files and asserts that they are identical
mkdir -p .internals/formatstrings/diff-english
errorCode=0
for language in "${ALL_LANGUAGES[@]}"; do
	if [ "$language" == "English" ]; then
		continue;
	fi
	# make a regex file to get only the keys the language has
	sort $inputFolder/$language.txt | cut -d'=' -f1 | sort > .internals/keys/$language.txt
	sed 's/^/\^/' .internals/keys/$language.txt | sed 's/$/\$/' > .internals/keyregexes.txt
	diff .internals/formatstrings/English.txt .internals/formatstrings/$language.txt | grep "=" | cut -d' ' -f2 | cut -d'=' -f1 |
		grep -f .internals/keyregexes.txt > .internals/formatstrings/diff-english/$language.txt
	SORTDIFF_LINES=`wc -l .internals/formatstrings/diff-english/$language.txt | awk {'print $1'}`;
	if [[ $SORTDIFF_LINES -gt 0 ]]; then
		errorCode=1;
		printf "%19s format: %3i errors\n" $language $SORTDIFF_LINES;
		if [ $summary -eq 0 ]; then
			cat .internals/formatstrings/diff-english/$language.txt;
		fi
	fi
	if [ $summary -eq 1 ]; then
		rm .internals/formatstrings/diff-english/$language.txt;
		rm .internals/formatstrings/$language.txt;
	fi
done

if [ $summary -eq 1 ]; then
	rm .internals/formatstrings/English.txt;
fi

if [ $summary -eq 0 ]; then
	if [ $errorCode -gt 0 ]; then
		echo "";
		echo "For more information, you can examine the temporary files that have just been made:"
		echo "Examine .internals/formatstrings/diff-english/[languagename].txt to see all keys for that language that have formatstrings different from English.";
		echo "Examine .internals/formatstrings/[languagename].txt to see all formatstrings {[number]} for that language by key.";
		echo "Note that formatstrings.sh may return false positives if the translations were not sorted to begin with. Run sort.sh to fix the sorting first.";
		echo "Also, all missing keys in any language are also listed as errors here. Run keysmatch.sh first to see what is missing.";
	fi
fi

exit $errorCode;
