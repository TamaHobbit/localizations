# Same as addtranslations.sh, except that conflicted keys resulting from merging the two are removed from the destination before merging.
# this means translations are lost in the destination target, being overwritten by those in the new translations (first parameter).
# For the opposite, merging in only non-conflicting translations, you should make a new database (empty folder), first add the translations
# you want to be partially overwritten, and then add the leading translations with fixup.sh
# $1, parameter 1: The folder containing English.txt, Danish.txt etc. with just the corrections from translators. E.g. tests/fixup/dutchpatch/
# $2, parameter 2: Destination folder containing existing localizations to merge the input with. E.g. all_translations/
# Examples:
# fixup.sh tests/fixup/dutchpatch/ all_translations/
# fixup.sh ../localizations/all_translations/ Assets/Resources/

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;
destinationFolder=`echo $2 | sed 's/\/$//'`;

rename.sh $inputFolder/

mkdir -p .internals
mkdir -p .internals/fixup

source langlist.sh
for language in "${ALL_LANGUAGES[@]}"; do
	cut -d'=' -f1 $inputFolder/$language.txt | sed 's/^/\^/' | sed 's/$/=/' > .internals/$language-regexes.txt
	# grep excluding those in the patch
	grep -v -f .internals/$language-regexes.txt -i $inputFolder/$language.txt -o .internals/fixup/$language.txt
	# move the result into the input to delete those translations
	mv .internals/fixup/$language.txt $inputFolder/$language.txt
done

addtranslations.sh $inputFolder $destinationFolder
