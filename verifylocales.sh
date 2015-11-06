# Verifies that every locale has the same recursive subfolders matching it.
# Intended to verify a collection of localizations was exported correctly
# $1, parameter 1: Root directory (containing (subfolders with) ar/ da/ es-419/ etc. folders)

# The empty line above is important, it distinguishes between the usage message (printed) and the code
# If no parameters, print help atop this shell file
if [ -z $1 ]; then
	sed -e '/^$/,$d' $0;
	exit 1;
fi

mkdir .internals -p
mkdir .internals/locales -p
rm -f .internals/locales/everything.txt

LOCALES=("ar" "da" "de" "en" "es" "fr" "it" "ja" "ko" "nb" "nl" "pt" "ru" "sv" "th" "tr" "zh-CN" "zh-TW" "pl" "fil" "fa" "id" "vi" "ms");

for locale in "${LOCALES[@]}"; do
	find -type d | grep -v "./.git/" | grep "/$locale\(-...\?\)\?$" |
	# find all occurences of locale foldername with optional suffix like -419 or -TW 
	# (\? makes the last thing optional, which is used both for "2 or 3 dots" and, using a group \( group \), for the suffix as a whole
	rev | cut -d'/' -f2- | rev | sort > .internals/locales/$locale.txt;
	# remove from the last / to the end of the line, to get the folder containing the localization file
	cat .internals/locales/$locale.txt >> .internals/locales/everything.txt
done

sort -u .internals/locales/everything.txt > tmp.txt;
mv tmp.txt .internals/locales/everything.txt;

for locale in "${LOCALES[@]}"; do
	echo "Printing missing projects for $locale";
	comm -23 .internals/locales/everything.txt .internals/locales/$locale.txt;
done
