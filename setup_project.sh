#!/bin/bash
#This is a  shell script that automates the creation of the workspace, configures settings via the command line, and handles system signals gracefully.


#Global Function
parent_dir=""
input=""

#Sigint trap function
cleanup_interrupt(){
echo "Interrupt signal received. Process stopped"
sleep 1
echo "Beginning cleanup process... "
    if [ -d "$parent_dir" ]; then 
    echo "Directory found. Beginning archiving process"
    sleep 1
    archive_name="${parent_dir}_archive.tar.gz"
    
    echo "Bundling current directory"
        if tar -czf "$archive_name" "$parent_dir" 2>/dev/null ; then
            echo "Archive created successfully"
            sleep 1
        else
            echo "Failed to create archive"
        fi
        echo "Removing directory" #deleting incomplete directory
        rm -rf "$parent_dir"
        
    fi
    echo "Cleanup Completed"
    exit 130
    }

# Prompt the user for the project name
directory_structure(){
read -rp "Please enter your directory name " input
parent_dir="attendance_tracker_$input"
#Create directory with user input


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

#Create files in respective directories
#Get code from files and copy to respective scripts
create_files(){
#Create attendance_checker.py
echo "Creating necessary files..."
sleep 1
echo "Creating attendance_checker.py"
sleep 1

    cat > "${parent_dir}/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

#Check if attendance_checker.py was created successfully AND not empty
if [ -f "${parent_dir}/attendance_checker.py" ] && [ -s "${parent_dir}/attendance_checker.py" ]; then
    chmod +x "${parent_dir}"/attendance_checker.py
    echo "attendance_checker.py created successfully. Ready to create config.json"
    sleep 1
else
    echo "Failure. Could not create attendance_checker.py. Exiting now... "
    exit 1
fi
 
#==================
#Create config.json
echo "Creating config.json..."
sleep 1
cat > "${parent_dir}/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}


EOF
#Check if config.json was created successfully AND not empty
if [ -f "${parent_dir}/Helpers/config.json" ] && [ -s "${parent_dir}/Helpers/config.json" ]; then
    echo "config.json created successfully. Ready to create assets.csv"
    sleep 1
else
    echo "Failure. Could not create config.json. Exiting now... "
    exit 1
fi
#==================
#Create assets.csv
echo "Creating assets.csv... "
sleep 1

cat > "${parent_dir}/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

#Check if assets.csv is was created successfully AND not empty

if [ -f "${parent_dir}/Helpers/assets.csv" ] && [ -s "${parent_dir}/Helpers/assets.csv" ]; then
    echo "assets.csv was created successfully. Ready to create reports.log"
    sleep 1

else
    echo "Failure. Could not create assets.csv. Exiting now... "
    exit 1
fi

#=============
#Create reports.log

cat > "${parent_dir}/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.


EOF

#Check if reports.log is was created successfully AND not empty

if [ -f "${parent_dir}/reports/reports.log" ] && [ -s "${parent_dir}/reports/reports.log" ]; then
    echo "reports.log was created successfully."
    sleep 1

else
    echo "Failure. Could not create reports.log. Exiting now... "
    exit 1
fi


echo "Files created successfully!"
}

#Stream Editing - user to decide if they want to update the attendance thresholds.
update_config(){
read -rp "Would you like to update the attendance threshold? (Y/N): " update_threshold
if [ "$update_threshold" = "Y" ]; then
    #default threshold values
    warning_threshold=75
    failure_threshold=50

while true; do #while loop for $warning_input
    read -p "Please insert new warning threshold values (0-100): " warning_input

    #Validate that $warning_input is a valid number
    if ! [[ "$warning_input" =~ ^[0-9]+$ ]]; then
        echo "Error: Please enter a valid number"
        continue 
    fi

    #Validate that $warning_input >0-100< 
    if [ "$warning_input" -lt 0 ] || [ "$warning_input" -gt 100 ]; then
        echo "Error: Please insert a number between 0-100: "
        continue
    fi


break
done

    if sed -i '' "s/$warning_threshold/$warning_input/g" "${parent_dir}/Helpers/config.json"; then
        echo "Warning threshold updated successfully to $warning_input."
        sleep 2
    else
        echo "Failed to update warning threshold."
        exit 1
    fi



while true; do #while loop for $failure_input
    read -rp "Please insert new failure threshold values (0-100): " failure_input

    #Validate that $failure_input is a valid number
    if ! [[ "$failure_input" =~ ^[0-9]+$ ]]; then
        echo "Error: Please enter a valid number"
        continue 
    fi

    #Validate that $warning_input >0-100< 
    if [ "$failure_input" -lt 0 ] || [ "$failure_input" -gt 100 ]; then
        echo "Error: Please insert a number between 0-100: "
        continue 
    fi

break
done


    if sed -i '' "s/$failure_threshold/$failure_input/g" "${parent_dir}/Helpers/config.json"; then
        echo "Failure threshold updated successfully to $failure_input."
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
            sleep 1
            echo "Now checking for subdirectories... "
            sleep 2
        fi

        #Checking if Subdirectories exist
        if [ ! -d "$parent_dir/Helpers" ]; then
            echo "'/Helpers' subdirectory is missing"
        elif [ ! -d "$parent_dir/reports" ]; then
            echo "'/reports' subdirectory is missing"
        else
            echo "It seems all is well here too... Carry on!"
            sleep 2
        fi
}

#Environment Health Check - Check if Python is installed on system
environment_check(){
    if python3 --version &>/dev/null; then
        echo "Python is installed. Continuing with setup... "
        sleep 1
    else 
        echo "Python is not yet installed. Please install Python before setup."
        sleep 1
        echo "exiting now... "
        sleep 1
        exit
    fi
}

#MAIN OPERATIONS
trap cleanup_interrupt SIGINT
environment_check
directory_structure
create_files
verify_folder_structure
update_config
