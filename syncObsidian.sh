#!/bin/bash

# Define paths to your iCloud and Dropbox folders
icloudFolder="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/iPhoneObsidinVault"
dropboxFolder="$HOME/Library/CloudStorage/Dropbox/BIG/Persoonlijk/ObsidianVaults"
deleteFile="_delete.md"
deletedFile="_beenDeleted.md"

# Ensure _delete.md and _beenDeleted.md exist in both directories
touch "$icloudFolder/$deleteFile" "$dropboxFolder/$deleteFile"
touch "$icloudFolder/$deletedFile" "$dropboxFolder/$deletedFile"


# Concatenate _delete.md files from both folders into one in the Dropbox folder
cat "$icloudFolder/$deleteFile" "$dropboxFolder/$deleteFile" | sort | uniq > "$dropboxFolder/${deleteFile}_combined"
mv "$dropboxFolder/${deleteFile}_combined" "$dropboxFolder/$deleteFile"

# Function to delete files or folders (by the arguments that are passed)
delete_file_or_dir() {
    local folder=$1
    local fileToDelete=$2
    local deletedFile=$3

    if [ -f "$folder/$fileToDelete" ]; then
        rm "$folder/$fileToDelete"
        echo "$fileToDelete" >> "$folder/$deletedFile"
    elif [ -d "$folder/$fileToDelete" ]; then
        if [ -z "$(ls -A "$folder/$fileToDelete")" ]; then
            rmdir "$folder/$fileToDelete"
            echo "$fileToDelete" >> "$folder/$deletedFile"
        fi
    fi
}

# Function to delete files from both folders
delete_files() {
    local fileToDelete=$1
    delete_file_or_dir "$icloudFolder" "$fileToDelete" "$deletedFile"
    delete_file_or_dir "$dropboxFolder" "$fileToDelete" "$deletedFile"
}

while IFS= read -r line || [[ -n "$line" ]]; do
    delete_files "$line"
done < "$dropboxFolder/$deleteFile"

# Empty the _delete.md file after processing
> "$icloudFolder/$deleteFile"
> "$dropboxFolder/$deleteFile"

# Continue with the rest of the sync, excluding the _delete.md, _beenDeleted.md files, and the .obsidian folder
rsync -au --exclude "$deleteFile" --exclude "$deletedFile" --exclude '.DS_Store' --exclude '.obsidian/' "$icloudFolder/" "$dropboxFolder/"
rsync -au --exclude "$deleteFile" --exclude "$deletedFile" --exclude '.DS_Store' --exclude '.obsidian/' "$dropboxFolder/" "$icloudFolder/"