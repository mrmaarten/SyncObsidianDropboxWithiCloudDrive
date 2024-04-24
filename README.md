# Script to sync Obsidian Vault between Dropbox and iCloud
This way I can sync between desktop computers that save to dropbox and iOS devices that save to iCloud.

I have the Obsidian Vaults on Dropbox, on iOS this doesn't work, so on my Mac Mini iSync between Dropbox and iCloud every minute.

I had to give Cron permissions 

### Grant Full Disk Access to `cron`

As of the last update, macOS doesn't directly list background processes like `cron` in the Full Disk Access pane of Security & Privacy settings. Instead, you need to grant access either to the Terminal app (which you've done) or specifically to the cron service. Here's a method to try:

1. **Open the Terminal.**
    
2. Enter the following command to open the Full Disk Access configuration in System Preferences:
    
    bashCopy code
    
    `open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"`
    
3. You'll likely need to unlock the padlock icon at the bottom left of the window to make changes. Click it and enter your password when prompted.
    
4. The tricky part is adding `cron` to this list, as it won't be found by the `+` button's standard Finder interface. Instead, you'll need to use Finder's "Go to the Folder" feature (from the Go menu or using `Shift+Cmd+G` in Finder) to navigate directly to `cron`'s location and then drag it into the Full Disk Access window. Here's the path you'll want:
    
    bashCopy code
    
    `/usr/sbin/cron`
    
5. Once you've navigated to `/usr/sbin/` in Finder, you might not see `cron` listed (since system files are hidden by default). You can make hidden files visible by pressing `Shift+Cmd+.` (period key), then drag `cron` into the Full Disk Access list.
    
6. After adding `cron` to Full Disk Access, lock the padlock icon again to prevent further changes.

Set up the CronTab with

`crontab -e`

