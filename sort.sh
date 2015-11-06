# Sorts all files; assumes our format, i.e. 1 folder with 18 files such as English.txt and Danish.txt
# $1, parameter 1: The destination folder containing the existing translations to sort
# Examples:
# sort.sh iap_keys/
# sort.sh ../../cig2/Assets/Resources/

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

source langlist.sh
for language in "${ALL_LANGUAGES[@]}"; do
	sort $inputFolder/$language.txt -o $inputFolder/$language.txt
done
