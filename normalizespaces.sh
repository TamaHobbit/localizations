# Makes sure there is no whitespace around the "=" character in all languages in the given folder
# $1, parameter 1: The folder containing English.txt, Danish.txt etc. to normalize

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
	normalizefilespaces.sh $inputFolder/$i.txt
done
