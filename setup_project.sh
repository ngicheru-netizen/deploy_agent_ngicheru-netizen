#!/bin/bash
#This is a  shell script that automates the creation of the workspace, configures settings via the command line, and handles system signals gracefully.

# Prompt the user for the project name
directory_structure(){
read -p "Please enter your directory name" input

#Create directory with user input
parent_dir="attendance_tracker_$input"

if mkdir -p "$parent_dir"; then
    echo "Parent directory created"
    sleep 2
else 
    echo "Failed to create parent directory"
    exit 1

fi
echo "Creating subdirectories..." 
sleep 2

#create subdirectories
if mkdir -p "$parent_dir/Helpers" "$parent_dir/reports"; then

    echo "Subdirectories created successfully"
    sleep 1
else
    echo "Failed to create subdirectories in $parent_dir"
    exit 1
fi
}

#Move downloaded files into respective directories
create_files(){
mv assets.csv attendance_tracker_"$input"/Helpers
mv config.json attendance_tracker_"$input"/Helpers
mv reports.log attendance_tracker_"$input"/reports

echo "Files moved successfully!"
}

#Stream Editing - user to decide if they want to update the attendance thresholds.
update_config(){

read -rp "Would you like to update the attendance threshold? {Y/N}" update_threshold
if $update_threshold '==' "Y"; then
    #default threshold values
    warning_threshold=75
    failure_threshold=50

    read -p "Please insert new warning threshold values (0-100)" warning_input
    if sed -i 's/$warning_threshold/$warning_input/g' attendance_tracker_$input/Helpers/config.json; then
        echo "Warning threshold updated successfully."
        sleep 2
    else
        echo "Failed to update warning threshold."
        Exit 1
    fi
    read -p "Please insert new failure threshold values (0-100)" failure_input
    if sed -i 's/$failure_threshold/$ailure_input/g' attendance_tracker_$input/Helpers/config.json; then
        echo "Failure threshold updated successfully."
        sleep 2
    else
        echo "Failed to update failure threshold."
    fi
else
    echo "No changes were made to attendance threshold"
    sleep 1
fi
}

#Verify folder structure
verify_folder_structure(){
    echo "Double checking that folder structure is in order..."
    sleep 2
        #Checking if Parent directory exists
        if [ ! -d "$parent_dir" ]; then
            echo "Parent directory is missing."
        else
            echo "All is well!"
        fi

        #Checking if Subdirectories exist
        if [ ! -d "$parent_dir/Helpers" ]; then
            echo "'/Helpers' subdirectory is missing"
        elif [ ! -d "$parent_dir/reports" ]; then
            echo "'/reports' subdirectory is missing"
        else
            echo "It seems all is well here too... Carry on!"
        fi
}

