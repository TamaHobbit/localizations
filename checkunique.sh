# Checks for duplicate keys in a given localization folder, for all 18 languages
# $1, parameter 1: The folder containing English.txt, Danish.txt etc. with just the new diff from translators
# Example: checkunique.sh iap_notification/
# Flags:
# -s	short, human readable summary with for each language, just the number of conflicted keys

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

summary=0;
if [ ! -z $2 ]; then
	if [ $2 == "-s" ]; then
		summary=1;
	fi
fi

invalidFiles=0;

mkdir .internals/dup -p;

source langlist.sh
for i in "${ALL_LANGUAGES[@]}"; do
	TMPFILENAME=`echo "$inputFolder/$i.txt" | rev | cut -d"/" -f1 | rev`;
	checkfileduplicates.sh $inputFolder/$i.txt > .internals/dup/$TMPFILENAME;
	duplicateLines=`wc -l .internals/dup/$TMPFILENAME | cut -d' ' -f1`;
	if [[ $duplicateLines -gt 0 ]]; then
		printf "Found %i duplicate keys in %19s.txt\n" $duplicateLines $i;
		invalidFiles=$(($invalidFiles + 1));
		if [ $summary -eq 0 ]; then
			cat .internals/dup/$TMPFILENAME;
			echo "";
		fi
	fi
	if [ $summary -eq 1 ]; then
		rm .internals/dup/$TMPFILENAME;
	fi
done

if [ $summary -eq 0 ]; then
	cat .internals/dup/*.txt | sort | uniq > .internals/dup/anylanguage.txt
fi

exit $invalidFiles; # 0 invalid files means success, everything else is an "error code" indicating how many invalid files























