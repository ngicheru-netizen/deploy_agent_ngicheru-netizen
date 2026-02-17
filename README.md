# Readme

# Run Through Video

Run through video in comments section on summative submission on Canvas.

### How to Run the Script

First, make sure the script has execute permissions:

```sh
chmod +x setup_project.sh
```

Then run the script:

```sh
./setup_project.sh
```

Or you can use:

```sh
bash setup_project.sh
```

### How to Trigger the Archive

To trigger the archiving process, press `Ctrl+C` while the script is running.

### What the Script Produces

- Prepares the environment, creates and organizes necessary files.
- Archives or backs up files when triggered.

## Something to watch out for

Lines 231 and 260
Added [''] after [ sed -i ] because I kept getting an error when trying to change warning & failure threshold values:

[ sed: 1: "attendance_tracker_v2/H ...": command a expects \ followed by text
Failed to update warning threshold. ]

According to the internet - This error means sed is interpreting part of your file path as a sed command. Apparently on macOS/BSD systems, sed -i requires a backup extension after the -i flag, even if you don't want a backup.
