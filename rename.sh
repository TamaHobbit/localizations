# Renames the folderstructure the translators provide to what our localization code expects (Danish.txt, Portugese.txt etc. all in one folder)
# $1, parameter 1: The folder containing English.txt, Danish.txt etc. with just the new diff from translators
# Example: rename.sh iap_notification/

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

# in all scripts, if a folder is passed with trailing /, remove it and continue
inputFolder=`echo $1 | sed 's/\/$//'`;

cat $inputFolder/ar*/*.txt > $inputFolder/Arabic.txt
cat $inputFolder/da*/*.txt > $inputFolder/Danish.txt
cat $inputFolder/de*/*.txt > $inputFolder/German.txt
cat $inputFolder/en*/*.txt > $inputFolder/English.txt
cat $inputFolder/es*/*.txt > $inputFolder/Spanish.txt
cat $inputFolder/fr*/*.txt > $inputFolder/French.txt
cat $inputFolder/it*/*.txt > $inputFolder/Italian.txt
cat $inputFolder/ja*/*.txt > $inputFolder/Japanese.txt
cat $inputFolder/ko*/*.txt > $inputFolder/Korean.txt
cat $inputFolder/nb*/*.txt > $inputFolder/Norwegian.txt
cat $inputFolder/nl*/*.txt > $inputFolder/Dutch.txt
cat $inputFolder/pt*/*.txt > $inputFolder/Portugese.txt
cat $inputFolder/ru*/*.txt > $inputFolder/Russian.txt
cat $inputFolder/sv*/*.txt > $inputFolder/Swedish.txt
cat $inputFolder/th*/*.txt > $inputFolder/Thai.txt
cat $inputFolder/tr*/*.txt > $inputFolder/Turkish.txt
cat $inputFolder/zh-CN/*.txt > $inputFolder/Chinese_Simplified.txt
cat $inputFolder/zh-TW/*.txt > $inputFolder/Chinese_Traditional.txt

cat $inputFolder/pl*/*.txt > $inputFolder/Polish.txt
cat $inputFolder/fil*/*.txt > $inputFolder/Filipino.txt
cat $inputFolder/fa*/*.txt > $inputFolder/Farsi.txt
cat $inputFolder/id*/*.txt > $inputFolder/Indonesian.txt
cat $inputFolder/vi*/*.txt > $inputFolder/Vietnamese.txt
cat $inputFolder/ms*/*.txt > $inputFolder/Malay.txt

normalizespaces.sh $inputFolder/
sort.sh $inputFolder/
