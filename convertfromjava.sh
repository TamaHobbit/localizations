# Replaces Java format specifiers with C# ones: %1$d -> {0}
# $1, parameter 1: The folder containing text files to convert
# Example: convertfromjava.sh iap_notification/

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

for i in {1..9}
do
	find $inputFolder -type f | xargs -n 1 sed "s/%$i\$[s|d]/{$(($i-1))}/" -i
done

find $inputFolder -type f | xargs -n 1 sed 's/%[d|s]/{0}/g' -i
