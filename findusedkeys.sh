# Use this from the root of a Unity project to find all UILocalize components in scenes, prefabs, and C# code
# It overwrites your usedkeys.txt with a new version that contains all the simple keys; 
# if you have code that constructs keys without directly passing them to Localization.Get, this script will not find them correctly
# but will output the C# code and filename that used Localization.Get in the non-standard manner

# find in scenes
grep "key: " Assets/Scenes/*.unity | cut -d' ' -f4 > usedkeys.txt
# find in prefabs (note this gives false positives "Alpha" and "Scale" from some prefabs, such as CIG4's OverlayAlphaAnimation.prefab and OverlayDarkAlphaAnimation.prefab
find Assets/Prefabs/ -type f -name "*.prefab" | xargs -I {} grep "key: " "{}" | cut -d' ' -f4 >> usedkeys.txt
# find in C# code; Localization.Get("key")
find Assets/ -name *.cs | xargs grep -oh "Localization.Get(\"[^\)]*\")" | cut -d'"' -f2 >> usedkeys.txt
# find stringReferences in properties file
grep ".stringReference" Assets/objects.properties.txt | cut -d'=' -f2 | tr -d ' ' | sort | uniq >> usedkeys.txt
# find all building names; this works for CVIS, which doesn't have stringReferences, but other games such as CIG3 do not localize the actual building name, 
# so this is commented by default -uncomment the following line if you are processing a game without stringReferences
#grep ".type =" Assets/objects.properties.txt | tr -d ' ' | grep -v "route" | grep -v "island" | cut -d'.' -f1 | sort | uniq >> usedkeys.txt


sort usedkeys.txt | uniq > tmp.txt
mv tmp.txt usedkeys.txt

#print the rest
echo "The rest are non-standard usages of Localization.Get(), with a variable passed in, or other bullshit you will have to find out for yourself:"

find Assets/ -name *.cs | xargs grep "Localization.Get[^\(]\|Localization.Get([^\"]\|Localization.Get(\"[^\)]*\"[^\)]"

echo "Afterwards, you will want to do something like; `sort usedkeys.txt | uniq > tmp.txt; mv tmp.txt usedkeys.txt` to get rid of any duplicates you may have introduced"