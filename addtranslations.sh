# Add translations to a folder (default is all_translations), 
# given a folder from the translators containing 18 folders like: "ar/random_name_with_date.txt", with one for each of 18 country codes.
# addtranslations.sh will squash any duplicate keys into a single line if and only if the key and value both match.
# That's why it tells you afterwards that you should check the `status.sh $2` of the result to check for duplicate keys.
# If you encounter duplicates after adding translations, git will tell you which translation you have just added so that you can resolve the conflict.
# $1, parameter 1: The folder containing English.txt, Danish.txt etc. with just the new diff from translators
# $2, parameter 2: (Optional) Destination folder containing existing localizations to merge the input with. Default is all_translations/
# Examples:
# addtranslations.sh iap_notification/
# addtranslations.sh input/2015-11-06-iap-pack-keys.txt/ ../CIG3/Assets/Resources/

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

DESTINATION=${2:-all_translations/} #if unset or null (empty string), use all_translations/
ENGLISH_DIR=($inputFolder/"en/");
test -e $ENGLISH_DIR;
if [ $? -eq 0 ]; then
	rename.sh $inputFolder/
else
	ENGLISH_DIR=($inputFolder/"en-US/");
	test -e $ENGLISH_DIR;
	if [ $? -eq 0 ]; then
		rename.sh $inputFolder/
	fi
fi

test -e $inputFolder/"English.txt";
if [ $? -gt 0 ]; then
	echo "Error: $1 contains neither our format (18 files, named Language.txt), nor the translators format (18 folders, named by country code /en/whatever.txt etc)";
	exit 1;
fi

test -e $DESTINATION/"English.txt";
if [ $? -eq 0 ]; then
	normalizespaces.sh $DESTINATION
fi

merge_all.sh $inputFolder/ $DESTINATION

normalizespaces.sh $DESTINATION

sort.sh $DESTINATION

echo "You must now run \`status.sh" $DESTINATION "\` to check the resulting database";
