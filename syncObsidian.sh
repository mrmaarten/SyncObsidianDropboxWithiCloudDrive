#!/bin/bash

# Define paths to your iCloud and Dropbox folders
icloudFolder="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/iPhoneObsidinVault"
dropboxFolder="$HOME/Library/CloudStorage/Dropbox/BIG/Persoonlijk/ObsidianVaults"
deleteFile="_delete.md"
deletedFile="_beenDeleted.md"
deleteUnsuccess="_deleteUnsuccessfull.md"

# Ensure _delete.md and _beenDeleted.md exist in both directories
touch "$icloudFolder/$deleteFile" "$dropboxFolder/$deleteFile"
touch "$icloudFolder/$deletedFile" "$dropboxFolder/$deletedFile"
#make a temp file for unsuccessfull deletion
touch "$icloudFolder/$deleteUnsuccess" "$dropboxFolder/$deleteUnsuccess"

# Concatenate _delete.md files from both folders into one in the Dropbox folder
cat "$icloudFolder/$deleteFile" "$dropboxFolder/$deleteFile" | sort | uniq > "$dropboxFolder/${deleteFile}_combined"
mv "$dropboxFolder/${deleteFile}_combined" "$dropboxFolder/$deleteFile"

# Function to delete files from both folders
delete_files() {
    local fileToDelete=$1
    # Attempt to delete from iCloud folder
    # checks if it is a file or directory
   if [ -f "$icloudFolder/$fileToDelete" ] || [ -d "$icloudFolder/$fileToDelete" ]; then
        rm -r "$icloudFolder/$fileToDelete"

        #check for success or failure of deletion
        if [ $? -eq 0 ]; then
            echo "$fileToDelete" >> "$icloudFolder/$deletedFile"
            echo "File successfully deleted."
        else
            echo "$fileToDelete" >> "$icloudFolder/$deleteUnsuccess"
            echo "File deletion failed."
        fi
    fi

    # Attempt to delete from Dropbox folder
    if [ -f "$dropboxFolder/$fileToDelete" ] || [ -d "$dropboxFolder/$fileToDelete" ]; then
        rm "$icloudFolder/$fileToDelete"
        if [ $? -eq 0 ]; then
            echo "$fileToDelete" >> "$icloudFolder/$deletedFile"
            echo "File successfully deleted."
        else
            echo "$fileToDelete" >> "$dropboxFolder/$deleteUnsuccess"
            echo "File deletion failed."
        fi
    fi
}

# Use the combined _delete.md in the Dropbox folder as the source for deletions
while IFS= read -r line || [[ -n "$line" ]]; do
    delete_files "$line"
done < "$dropboxFolder/$deleteFile"

# Empty the _delete.md file after processing
# > "$icloudFolder/$deleteFile"
# > "$dropboxFolder/$deleteFile"

#rename the deleteUnsuccess file to deleteFile
mv "$dropboxFolder/$deleteUnsuccess" "$dropboxFolder/$deleteFile"
mv "$icloudFolder/$deleteUnsuccess" "$icloudFolder/$deleteFile"

# Continue with the rest of the sync, excluding the _delete.md, _beenDeleted.md files, and the .obsidian folder
rsync -au --exclude "$deleteFile" --exclude "$deletedFile" --exclude '.DS_Store' --exclude '.obsidian/' "$icloudFolder/" "$dropboxFolder/"
rsync -au --exclude "$deleteFile" --exclude "$deletedFile" --exclude '.DS_Store' --exclude '.obsidian/' "$dropboxFolder/" "$icloudFolder/"