# Adds together all missing keys, printing a bunch of garbage followed by the total count
# $1, parameter 1: The input folder containing the main database

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

keysmatch.sh $inputFolder
echo "----------------------------------------------------"
echo "Done checking translations, total missing keys (you can retrieve it again faster with wc -l .internals/keys/untranslated/all.txt):"
cat .internals/untranslated_languagecount.txt | tr -s ' ' | cut -d ' ' -f2 | awk '{ sum+=$1} END {print sum}'
