# Imports new translations from OneSkyApp, overwriting whatever we already had for those keys. 
# This overwriting is the difference between it and addtranslations, which would end up with conflicted keys instead.
# When done, usedkeys.txt will have new translations; see git diff
# $1, parameter 1: Folder containing new localizations to import.
# $2, parameter 2: Destination folder; this should be onesky/; it uses the usedkeys.txt in there, and the all_translations/ directory
# Example: import.sh /c/Users/Tama/Downloads/2016-01-13.txt/ /e/repos/onesky

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;
oneskyfolder=`echo $2 | sed 's/\/$//'`;

# Reset onesky's usedkeys.txt since it might be out of date from other custom imports
extractused.sh $oneskyfolder/all_translations > $oneskyfolder/usedkeys.txt

# Establish the keys to be overwritten, remove them from onesky's usedkeys
rename.sh $inputFolder;
extractused.sh $inputFolder | removeusedkey.sh $oneskyfolder/usedkeys.txt

# Use export to apply the new usedkeys to oneskyfolder/all_translations, effectively discarding the localizations in the inputFolder
export.sh $oneskyfolder/all_translations $oneskyfolder/new_all_translations $oneskyfolder/usedkeys.txt
rm -rf $oneskyfolder/all_translations
mv $oneskyfolder/new_all_translations $oneskyfolder/all_translations

addtranslations.sh $inputFolder $oneskyfolder/all_translations

# Reset onesky's usedkeys.txt
extractused.sh $oneskyfolder/all_translations > $oneskyfolder/usedkeys.txt
