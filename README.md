# Scripts

These are the most commonly used scripts:

	status.sh -- check the status of translated files (in our Languagename.txt format), either of a (game's) database, or of the localizations to be added
	export.sh -- export from the onesky repository to your game's localization directory, but only the keys in the usedkeys.txt passed
	addtranslations.sh -- add translations in first parameter to database in second parameter
	extractused.sh -- Globs together all current localization files and extracts the keys that are in at least one language

These scripts are used when something went wrong, or for checking:

	rename.sh -- rename files you get from the translators into the format expected by our localization code. Called automatically whenever possible.
	checkunique.sh -- checks for duplicate keys in a given localization folder.
	keysmatch.sh -- checks whether the keys are identical in each language, prints the keys by language that do not. (no output means everything is fine)
	formatstrings.sh -- check whether format strings in keys match with English. (no output means everything is fine)
	sort.sh -- sort all localization files. This should be committed seperately.
	normalizespaces.sh -- remove all spaces surrounding "=" character. This should be committed seperately.
	findusedkeys.sh -- Search through C# code, Unity prefabs and scenes for components that might need localization, to determine what is needed. Prints everything it could not automatically detect on the console for you to fix.

All other script should not be needed, but most print usage instructions when running them without any arguments:

	merge_lang.sh
	
------------------------------------------------

# Installation: Get git bash, add this to PATH

For the terminal to run these scripts, either install GitBash or get something like GitExtensions or SourceTree, which have a terminal button so that you can easily open the terminal on a particular project. It is best to add the localization git repository path to your PATH environment variable (In windows; Advanced System Settings > Environment variables). That way, you can open git bash on any project and use the scripts:

	status.sh Assets/Resources usedkeys.txt

Note that my scripts make extensive usage of such unix commands as comm, find, sed etc. If you have e.g. the Ruby devkit installed, comm will refer to the wrong command! If something goes wrong, check `which comm` (if comm failed) to see if it is using GitBash's version of the command in question.
	
If you use these scripts from your project directory, the .internals folder containing the temporary files (e.g. which keys are missing in all languages) 
ends up in your project directory. These files are very useful for diagnosing what's wrong with the localizations (the output from some commands directs 
you to read certain files). It is recommended to not .gitignore this, because that way you can see them as a git diff. Never commit them to the repository 
though, as their contents change depending on which commands were run last.

------------------------------------------------

# Terminology

	untranslated -- Keys that are present in English but not in some other language. After a keysmatch.sh run, .internals/keys/untranslated/Danish.txt contains the keys for which the Danish translation is missing. .internals/keys/untranslated/all.txt contains keys that are only present in English.
	dirty-add -- Similarly, .internals/keys/dirty-add/ contains, for each language, the keys that are present in that language but not in English.
	conflicted keys -- Two identical keys with different values in some language is a conflict. Note that, after addtranslations.sh it is possible that some languages were merged without conflict, while others are not. If both the key and value is the same for two rows, addtranslations drops one and does not report a conflicted key.
	pending localization -- A localization, such as "download_now=Download now!", that is included in English.txt and usedkeys.txt for a game, but is not present in the onesky database. See "Requesting a new translation"
	
------------------------------------------------

# Scenario's

## Scenario 1: Need a text, don't know anything

Imagine you need to add "Download now!" to a button, localized. First, we need to figure out if we already have something suitable. Checkout the [onesky](https://gitlab.innovattic.com/suiss/onesky) repository, and open a terminal in the root of that, to grep through all_translations/*.txt for terms included:

```
grep "download" -i all_translations/English.txt
```

Now make a judgement call, or ask product owners; is "download_and_play=Download and play" good enough for the occasion? if ( need a new translation ){ goto "Requesting a new translation" }

### Step 1: Add existing localization

If you've found a localization that is good enough, add it by opening a GitBash terminal in the repository of the game;

```
addkey.sh usedkeys.txt[ENTER]
existing_key_I_found_in_onesky_repo[ENTER]
[Cntrl^D][ENTER]
```

Note that you can add multiple keys, each on a newline, before the Cntrl^D which signifies end of file. You can also pipe a list of usedkeys, to add all usedkeys from one game (or submodule?).

### Step 2: Export

You should now have a git diff showing you added that key to usedkeys.txt, in the alphabetically correct place. Then do something like this, which assumes your onesky repo is checked out next to the game in question:

```
export.sh ../onesky/all_translations Assets/Resources usedkeys.txt
```

If the status is clean, you are done. If the status was clean but is no longer clean, you may need to have some languages translated for the key in question, or may need to fix other unrelated keys that have been imported wrong . Use `missinglanguages.sh` to find out which languages need to be requested for that key.

## Scenario 2: Requesting a new translation

### Step 1: Add a pending localization

```
addkey.sh usedkeys.txt
my_new_key_needed[ENTER]
[Cntrl^D][ENTER]
```

Keep in mind that:
* The '=' character is forbidden in both keys and values, and is only used to seperate the two.
* There may not be any whitespace inside or preceding the key.
* the new key must not conflict with the onesky database, check with: grep "^my_new_key_needed=" ../onesky/all_translations/English.txt

Request the key and translation from SS in the SUISS localization channel, by posting the following, for example:

```
I need this for TCG!
download_now=Download now!
```

Append your translation to English.txt (don't worry about sorting). Commit these changes along with your feature, so that others know that the feature depends on pending localizations.

### Step 2: Update your code

Use the key in your code, using Localization.Get("download_now"). You may need to think of a translation already, so that you can test formatstrings or label sizes, but it need not be final.

### Step 3: Request the localization

In the SUISS localization slack channel, post your request for a new localization, for example:

```
I need this for TCG!
download_now=Download now!
```

SS is free to change the text, but usually will not unless you ask them to. A screenshot of your placeholder in-game may help for them to decide what is suitable.

------------------------------------------------

## Scenario 3: Receiving localizations

On the SUISS slack channel, SS will periodically post a zip file with new localizations. 
Download and unzip the localizations, check them, then add them to the onesky repository;

### Step 1: Check unzipped localizations

```
extractused.sh new_translations/ > usedkeys.txt
status.sh new_translations/ usedkeys.txt
```

If there's anything wrong, see "Receiving bad localizations".

### Step 2: Add to Onesky localizations

```
add_translations.sh new_translations/ onesky/all_translations
extractused.sh onesky/all_translations > onesky/usedkeys.txt
status.sh onesky/all_translations onesky/usedkeys.txt
```

The status of OneSky is allowed to have missing keys - that isn't a problem until a game uses incompletely translations. 
As long as the new translations came out clean, and there are no key-conflicts in onesky/all_translations, we can commit and push our addition.

### Step 3: Export to required games

```
export.sh onesky/all_translations gamefolder/Assets/Resources gamefolder/usedkeys.txt
status.sh gamefolder/Assets/Resources gamefolder/usedkeys.txt
```

### Step 4: Oh no! What are all these other changes?

Fixes to translations are done in onesky, so each new export will bring in fixes done since the last export. If there are any changes other than new translations, then the game previously had invalid localization files. You should accept all changes from the export, but you will need to check for:
* Localizations that are removed by the export; if used by the game, they should be added to usedkeys.txt (see "Add existing localization")
* Localizations that are changed such that the format parameters are different; the game code might crash if it expects more format parameters than it gets; you should change it to either expect the right format parameters, or to use a new key with the old contents (you can extract this from the previous game repository, use changekey.sh and add it to onesky)

------------------------------------------------

## Scenario 4: Receiving bad localizations

After downloading and unzipping the localizations file, status.sh new_translations/ on it prints errors. For each block with errors, 
I run the command it says will give more information and reply in the SUISS localization channel, listing the errors. 

If some languages are missing, and there is a pressing need for a build with the translations before these missing languages are received, 
I could commit and push anyway. In that case (after getting cookies for the team), when the new translations come in, I can add them without risk of conflict -
since both key and value will match for the existing languages. However, if the missing translations never arrive, the error in the localizations database 
will persist.

------------------------------------------------

## Scenario 5: Two people needing the same new localization

Johnny and myself are working on SSP, with him working on CIG4 while I am working on BERW. When I want to request the new key, I see in the slack channel 
that Johnny has already requested this localization, so I just modify my code to use his key and discard or revert my changes.

------------------------------------------------

## Scenario 6: Spelling / grammar error? Content update?

At some point, either a player or SS or a developer finds an error in a translation. This should be edited directly in the onesky repository, committed and pushed
and then exported to games as needed.

This is considerably easier than when the localization contents need to be changed. For instance, the text for the rating request popup is modified to 
include completely different text. This means a new key should be made, modified in game-code and requested. 

If a significant change were to be handled as an error,
it would have to be modified seperately in all languages, and there would be no choice but to push it to all games (eventually, on their next export), and 
there is no easy way to retrieve the old translation - we would have to revert and re-add it with a new key. This means we should be very wary with 
modifying keys. Reserve that strictly for typo's and grammatical errors.

So, it may be a judgement call whether a change is an error or a change in content, especially when the English was incorrect, and may have been translated incorrectly by some translators. When in doubt, make a new key and leave the old one, so that other games can choose not to accept the change.

------------------------------------------------
