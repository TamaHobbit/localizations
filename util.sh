# Defines common functions; never use, only include

# Given array and element, returns 1 if the element is in the array. E.g. array_contains ALL_LANGUAGES[@] "Danish";
array_contains () {
	declare -a array=("${!1}");
	for i in "${array[@]}"; do
		# echo "Comparing" $i "to" $2; #for debugging
		if [ "$i" = "$2" ]; then
			return 1;
		fi
	done
	return 0;
}

# Given a diff-file, this returns the number of lines starting with > or <
diff_lines () {
	return `cat $1 | grep "^[<|>]" | wc -l | tr -s ' ' | cut -d' ' -f2`;
	# tr -s ' ' | cut -d' ' -f2 is to get the first non-whitespace characters, which is the number of lines in the diff
}