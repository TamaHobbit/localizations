# Imports new translations from OneSkyApp, overwriting whatever we already had for those keys. 
# This overwriting is the difference between it and addtranslations, which would end up with conflicted keys instead.
# When done, usedkeys.txt will have new translations, and localization files will also contain corrections; check the git diff before committing & pushing
# $1, parameter 1: Destination folder - this should be onesky/; it uses the usedkeys.txt in there, and the all_translations/ directory
# $2-, parameters 2 and following: Folders containing new localizations to import.
# Examples: 
# import.sh /e/repos/onesky /c/Users/Tama/Downloads/2016-01-13.txt/
# import.sh /e/repos/onesky *

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
oneskyfolder=`echo $1 | sed 's/\/$//'`;
# Get parameters 2 and following into an array
sourceImportDirs=`echo ${@:2} | sed 's_\/$__g' | sed 's_\/ _ _g' | tr " " "\n"`

echo "Resetting $oneskyfolder/usedkeys.txt since it might be out of date from e.g. calling addtranslations.sh directly"
extractused.sh $oneskyfolder/all_translations > $oneskyfolder/usedkeys.txt

echo "Establishing keys to be overwritten; see .internals/import_overwritingkeys.txt"
rm -f .internals/import_overwritingkeys.txt
for inputFolder in $sourceImportDirs; do
	rename.sh $inputFolder;
	extractused.sh $inputFolder >> .internals/import_overwritingkeys.txt
done

echo "Removing newly imported keys from $oneskyfolder/usedkeys.txt"
removeusedkeysin.sh $oneskyfolder/usedkeys.txt .internals/import_overwritingkeys.txt

echo "Re-exporting $oneskyfolder/all_translations to itself, effectively discarding the existing localizations that are in the inputFolders"
export.sh $oneskyfolder/all_translations $oneskyfolder/new_all_translations $oneskyfolder/usedkeys.txt
rm -rf $oneskyfolder/all_translations
mv $oneskyfolder/new_all_translations $oneskyfolder/all_translations

echo "Adding translations:"
for inputFolder in $sourceImportDirs; do
	echo "===$inputFolder===";
	addtranslations.sh $inputFolder $oneskyfolder/all_translations
done

echo "Resetting $oneskyfolder/usedkeys.txt"
extractused.sh $oneskyfolder/all_translations > $oneskyfolder/usedkeys.txt
