# Add new texts, to be translated and used in game. You supply key=Value pairs in English,
# which are called "dirty translations", because they would be overwritten as soon as you 
# do an export from the main database. Your input to this script should be sent to translators.
# Type each new key=Value on a new line, followed up by Cntrl^D to signify end-of-file.
# You can also pipe in a text file with the translations to be added.
# $1, parameter 1: The current usedkeys.txt file, that should normally be in the root of your project
# $2, parameter 2: The English.txt target file, that should normally be in Assets/Resources/

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

cat | (while read line; do echo $line >> $2; echo $line | cut -d'=' -f1 >> $1; done)
sort -i $1 -o $1
