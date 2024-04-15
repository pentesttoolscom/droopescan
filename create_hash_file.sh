#!/bin/bash

# This script must be run within a drupal git repo

vergte() {
    [  "$1" = "`echo -e "$2\n$1" | sort -rV | head -n1`" ]
}

url_file_paths=("misc/drupal.js" "misc/tabledrag.js" "misc/tableheader.js" "misc/ajax.js" "core/misc/drupal.js" "core/misc/tabledrag.js" "core/misc/tableheader.js" "core/misc/states.js" "core/misc/ajax.js" "core/misc/vertical-tabs.js" "core/modules/ckeditor5/js/build/drupalImage.js" "core/modules/ckeditor5/js/build/drupalMedia.js" "core/assets/vendor/ckeditor/ckeditor.js" "core/yarn.lock" "core/modules/big_pipe/js/big_pipe.js")
changelog_file_paths=("CHANGELOG.txt" "core/CHANGELOG.txt")
output_file="../dscan/plugins/drupal/versions.xml"

if [ ! -d "drupal" ]; then
    git clone https://github.com/drupal/drupal
    if [ $? -ne 0 ]; then
        echo "Failed to clone the repository. Exiting..."
        exit 1
    fi
fi

cd drupal

tags=$(git tag --sort=v:refname)
tags=$(echo "$tags" | grep -E "[0-9]+")

exec 1>$output_file

echo \<cms\>
echo "  <files>"
for file_path in ${url_file_paths[@]}; do
    echo "    <file url=\"$file_path\">"
    for tag in $tags; do
        if git cat-file blob $tag:$file_path &> /dev/null; then
            echo "      <version md5=\"$(git cat-file blob $tag:$file_path | md5sum | head -c -4;)\" nb=\"$tag\" />"
        fi;
    done
    echo "    </file>"
done 2> /dev/null

for file_path in ${changelog_file_paths[@]}; do
    echo "    <changelog url=\"$file_path\">"
    for tag in $tags; do
        if git cat-file blob $tag:$file_path &> /dev/null; then
            echo "      <version md5=\"$(git cat-file blob $tag:$file_path | md5sum | head -c -4;)\" nb=\"$tag\" />"
        fi;
    done
    echo "    </changelog>"
done 2> /dev/null

echo "  </files>"
echo \</cms\>

cd ..
rm -R drupal/
