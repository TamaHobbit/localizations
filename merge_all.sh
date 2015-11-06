# Merges a Lang.txt formatted diff-set with destination folder (default is all_translations/), for all 18 languages
# $1, parameter 1: The folder containing English.txt, Danish.txt etc. with just the new diff from translators
# $2, parameter 2: Destination folder containing existing localizations to merge the input with. Default passed in by other scripts is all_translations/
# Example: merge_all.sh iap_notification/ example_database/

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

source langlist.sh
for i in "${ALL_LANGUAGES[@]}"; do
	merge_lang.sh $1 $i $2
done