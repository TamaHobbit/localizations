# Removes a key from a Lang.txt formatted translation set, for all 18 languages
# $1, parameter 1: Destination folder containing existing localizations to modify.
# $2, parameter 2: Key to remove
# Example: removekey.sh iap_notification/ Iron

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

source langlist.sh
for i in "${ALL_LANGUAGES[@]}"; do
	sed "/^$2=/d" $inputFolder/$i.txt > tmp.txt
	mv tmp.txt $inputFolder/$i.txt
done

