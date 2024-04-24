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

# Function to delete files from both folders
delete_files() {
    local fileToDelete=$1
    # Attempt to delete from iCloud folder
    if [ -f "$icloudFolder/$fileToDelete" ] || [ -d "$icloudFolder/$fileToDelete" ]; then
        rm -r "$icloudFolder/$fileToDelete"
        echo "$fileToDelete" >> "$icloudFolder/$deletedFile"
    fi

    # Attempt to delete from Dropbox folder
    if [ -f "$dropboxFolder/$fileToDelete" ] || [ -d "$dropboxFolder/$fileToDelete" ]; then
        rm -r "$dropboxFolder/$fileToDelete"
        echo "$fileToDelete" >> "$dropboxFolder/$deletedFile"
    fi
}

# Use the combined _delete.md in the Dropbox folder as the source for deletions
while IFS= read -r line || [[ -n "$line" ]]; do
    delete_files "$line"
done < "$dropboxFolder/$deleteFile"

# Empty the _delete.md file after processing
> "$icloudFolder/$deleteFile"
> "$dropboxFolder/$deleteFile"

# Continue with the rest of the sync, excluding the _delete.md, _beenDeleted.md files, and the .obsidian folder
rsync -au --exclude "$deleteFile" --exclude "$deletedFile" --exclude '.DS_Store' --exclude '.obsidian/' "$icloudFolder/" "$dropboxFolder/"
rsync -au --exclude "$deleteFile" --exclude "$deletedFile" --exclude '.DS_Store' --exclude '.obsidian/' "$dropboxFolder/" "$icloudFolder/"