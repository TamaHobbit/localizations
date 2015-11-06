# Scripts

These are the most commonly used scripts:

	status.sh -- check the status of translated files (in our Languagename.txt format), either of a (game's) database, or of the localizations to be added
	addtranslations.sh -- add translations in first parameter to database in second parameter

These extra scripts, which you only run when status.sh tells you to:

	rename.sh -- rename files you get from the translators into the format expected by our localization code. Called automatically whenever possible.
	checkunique.sh -- checks for duplicate keys in a given localization folder.
	keysmatch.sh -- checks whether the keys are identical in each language, prints the keys by language that do not. (no output means everything is fine)
	formatstrings.sh -- check whether format strings in keys match with English. (no output means everything is fine)
	sort.sh -- sort all localization files. This should be committed seperately.
	normalizespaces.sh -- remove all spaces surrounding "=" character. This should be committed seperately.

All other script should not be needed, but just like any other script, running them without any arguments prints usage instructions:

	merge_lang.sh

------------------------------------------------

# Terminology

	untranslated -- Keys that are present in English but not in some other language. After a keysmatch.sh run, .internals/keys/untranslated/Danish.txt contains the keys for which the Danish translation is missing. .internals/keys/untranslated/all.txt contains keys that are only present in English.
	dirty-add -- Similarly, .internals/keys/dirty-add/ contains, for each language, the keys that are present in that language but not in English.
	conflicted keys -- Two identical keys with different values in some language is a conflict. Note that, after addtranslations.sh it is possible that some languages were merged without conflict, while others are not. If both the key and value is the same for two rows, addtranslations drops one and does not report a conflicted key.
				
	
------------------------------------------------
	
# Path
	
It is best to add the localization git repository path to your $PATH environment variable. That way, you can open git bash on any project and use the scripts:

	status.sh Assets/Resources

If you use these scripts from your project directory, the .internals folder containing the temporary files (e.g. which keys are missing in all languages) 
ends up in your project directory. These files are very useful for diagnosing what's wrong with the localizations (the output from some commands directs 
you to read certain files). It is recommended to not .gitignore this, because that way you can see them as a git diff. Never commit them to the repository 
though, as their contents change depending on which commands were run last.

------------------------------------------------

# Scenario's

## Scenario 1: Requesting a new translation

### Step 1: Add the key

    addnewkey.sh my_new_keyname{0}{1}

Keep in mind that:
* The '=' character is forbidden in both keys and values, and is only used to seperate the two.
* There may not be any whitespace inside or preceding the key.
* If the translation is to include formatstrings, the key itself must include the same formatstrings.

This adds your key to both your own game's usedkeys.txt and to the central one in the localizations repository. If it prints an ok status, commit and 
push to both. If it prints a conflicted-key error, revert and pick a different keyname.

### Step 2: Update your code

Use the key in your code. You may need to think of a translation already, so that you can test formatstrings or label sizes, but it need not be sent to 
the translators in the end.

### Step 3: Request the key

In the SUISS localization slack channel, post your request for a new key.

------------------------------------------------

## Scenario 2: Receiving localizations

Download and unzip the localizations into this repository in the translations folder:

    status.sh new_translations
    add_translations.sh new_translations all_translations
    export.sh new_translations gamefolder/Assets/Resources gameolder/usedkeys.txt

Since status.sh was clean, I can add the new translations to the main database (and then re-export for my game).

------------------------------------------------

## Scenario 3: Receiving bad localizations

After downloading and unzipping the localizations file, status.sh new_translations/ on it prints errors. For each block with errors, 
I run the command it says will give more information and reply in the SUISS localization channel, listing the errors. 

If some languages are missing, and there is a pressing need for a build with the translations before these missing languages are received, 
I could commit and push anyway. In that case (after getting cookies for the team), when the new translations come in, I can add them without risk of conflict -
since both key and value will match for the existing languages. However, if the missing translations never arrive, the error in the localizations database 
will persist.

------------------------------------------------

## Scenario 4: Receiving good localizations while current database contains errors

Imagine you have received the folder "iap_notification/" from translators, and your current game database is in "example_database/"

It is advisable to always first check the status.sh of the existing database, and the status.sh of the new input.

	status.sh example_database
	status.sh iap_notification/
	
There is a lot wrong with the current database, and for each problem, status.sh tells you which other scripts to run for more details / fixing.
Now try adding the iap_notification/ translations to the existing database all_translations.

	addtranslations.sh iap_notification/ example_database
	
Follow the instructions printed and check the status of the resulting database:

	status.sh example_database

Every bad input from the translators should be printed somehow by status.sh

------------------------------------------------

## Scenario 5: Two people needing the same new localization

Johnny and myself are working on SSP, with him working on CIG4 while I am working on BERW. When I want to request the new key, I see in the slack channel 
that Johnny has already requested this localization, so I just modify my code to use his key and discard or revert my changes.

------------------------------------------------

## Scenario 6: Spelling / grammar error? Content update?

At some point, either a player or SS or a developer finds an error in a translation. This should be edited directly in this repository, committed and pushed
and then exported to games as needed.

This is considerably easier than when the localization contents need to be changed. For instance, the text for the rating request popup is modified to 
include completely different text. This means a new key should be made, modified in game-code and requested. 

If it were to be handled as an error,
it would have to be modified seperately in all languages, there would be no choice but to push it to all games (eventually, on their next export), and 
there is no easy way to retrieve the old translation - we would have to revert and re-add it with a new key. This means we should be very wary with 
modifying keys. Reserve that strictly for typo's and grammatical errors.

------------------------------------------------


By the end of the localization-rock, all existing databases should print a clean status.
all_translations will in future contain a conflictless database to be exported for use in all games 
(it results from merging games with each other),
but you can also use ../CIG4/Assets/ for example, or ../BERW/Assets/Resources/ as input to the scripts in the meantime.