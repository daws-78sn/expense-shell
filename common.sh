#!.bin/bash
set -e #to check error on every line it will exit the code once error occurs

#to replace validate() command trap will be used.

handle_error(){
    echo "Error occurred at line $1": $1, error command: $2"
}

trap 'handle_error $LINENO "$BASH_COMMAND"' ERR 


USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#echo "Please enter your DB password:"
#read -s mysql_root_password 
#replace ExpenseApp@1 with ${mysql_root_password} in command to hide in script

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

check_root(){
if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access"
    exit 1
else
    echo "You are super user."
fi
}