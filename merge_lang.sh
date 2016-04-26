# Merges a Lang.txt formatted diff-set with $3, for the language given. all_translations/ folder can be overriden with optional third parameter
# $1, parameter 1: The folder containing English.txt, Danish.txt etc. with just the new diff from translators
# $2, parameter 2: The language to add the translations to
# $3, parameter 3: The destination folder containing the existing translations to merge with
# Example: First, you've run "rename.sh iap_notification/" to get the diffs in the correct format, then run
# merge_lang.sh iap_notification/ Arabic ../CIG3/Assets/Resources/

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;
destinationFolder=`echo $3 | sed 's/\/$//'`;

mkdir -p .internals
mkdir -p .internals/merging
echo "Merging" $2 "translations for" $1 "into" $destinationFolder;
rm -f .internals/merging/$2.txt #remove first, because we append to the file, rather than writing to it
test -e $destinationFolder/$2.txt;
if [ $? -eq 0 ]; then #test first, because cat -s is broken under mingw
	cat $destinationFolder/$2.txt >> .internals/merging/$2.txt;
fi
printf "\n" >> .internals/merging/$2.txt; 											#newline in case the original didn't end with a newline yet
cat $inputFolder/$2.txt >> .internals/merging/$2.txt;								#append the new keys
sort .internals/merging/$2.txt | sed '/^$/d' | uniq > .internals/mergetmp.txt;	#sort the new file, removing duplicate and empty lines
mv .internals/mergetmp.txt $destinationFolder/$2.txt;								#and replace main file
																						#result automagically ends with a new line, follows unix convention
