# Greps for a key in all project folders for a given language
# $1, parameter 1: A directory with (sub*)subfolders containing Language.txt files
# $2, parameter 2: The key to find
# $3, parameter 3: The language
# Example: findmissingkey.sh ../Onesky city_advisor_jobs_needed Dutch

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

find $inputFolder -type f | grep -v "./.git/" | grep -v "./.internals" | grep "$3.txt\$" | (while read file; do grep "$2" $file > tmp.txt; [ -s tmp.txt ] && echo $file; cat tmp.txt; rm tmp.txt; done)
