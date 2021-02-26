#!/bin/bash

year=$(date +"%Y")

snapshot_list_html=$(wget -qO- "https://minecraft.gamepedia.com/Category:Snapshots_released_in_${year}")

#Constrains the string to be between a certain <div> </div>
version_list_html=$(echo "$snapshot_list_html" | sed -n "/<div class=\"mw-category-group\">/,/<\/div>/p")

# To replace all occurrences ${parameter//pattern/string}

eol=$'\n'
version_list_html="${version_list_html//>/>$eol}"

#Get the last html link
last_link_line=""
while IFS= read -r line
do
if [[ $line == *"<a"* ]]; then
  last_link_line=$line
fi
done < <(printf '%s\n' "$version_list_html")

#Delete everything before the space in the string
last_link_line=$(echo "$last_link_line" | sed 's/.*\ //')

#Delete remaining html element
snapshot_version=${last_link_line%\">}

snapshot_html=$(wget -qO- "https://minecraft.gamepedia.com/Java_Edition_${snapshot_version}")
snapshot_html="${snapshot_html//>/>$eol}"

#Find line containing the server jar
snapshot_jar_html=""
while IFS= read -r line
do
if [[ ($line == *"<a"*) && ($line == *"server.jar"*) ]]; then
  snapshot_jar_html=$line
fi
done < <(printf '%s\n' "$snapshot_html")

#Delete everything before the space in the string
snapshot_jar_html=$(echo "$snapshot_jar_html" | sed 's/.*\ //')

#Delete remaining html element
snapshot_jar_html=${snapshot_jar_html#*\"}
snapshot_jar_html=${snapshot_jar_html%\">}

wget $snapshot_jar_html
