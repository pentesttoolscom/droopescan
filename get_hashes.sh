#!/bin/bash

# This script must be run within a drupal git repo

vergte() {
    [  "$1" = "`echo -e "$2\n$1" | sort -rV | head -n1`" ]
}

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
	echo "Usage: $0 file_path output [min_version] [max_version]"
	exit
fi

file_path=$1
output_file=$2
min_version=$3
max_version=$4

tags=$(git tag --sort=v:refname)
tags=$(echo "$tags" | grep -E "[0-9]+")
if ! [ -z "$min_version" ]; then
    filtered_tags=""
    for tag in $tags; do
        if vergte "$tag" "$min_version"; then
            filtered_tags="$filtered_tags $tag"
        fi
    done
    tags=$filtered_tags
fi
if ! [ -z "$max_version" ]; then
    filtered_tags=""
    for tag in $tags; do
        if vergte "$max_version" "$tag"; then
            filtered_tags="$filtered_tags $tag"
        fi
    done
    tags=$filtered_tags
fi

for tag in $tags; do
	if git cat-file blob $tag:$file_path &> /dev/null; then 
		echo \<version md5=\"$(git cat-file blob $tag:$file_path | md5sum | head -c -4;)\" nb=\"$tag\" /\>;
	fi;
done 2> /dev/null > $output_file
