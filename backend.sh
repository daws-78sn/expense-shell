#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access"
    exit 1
else
    echo "You are super user."
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disable Nodejs module"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enable Nodejs 20 module"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

id expense
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created... $Y SKIPPING $N"
fi

mkdir -p /app #-p will create if not exists
VALIDATE $? "Creating App directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading Expense Backend"

cd /app # or unzip /tmp/backend.zip -d /app
rm -rf /app/*  # it will remove existing files in the directory

unzip /tmp/backend.zip
VALIDATE $? "Extracted backend code"

npm install
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
#copying backend.service file from its absolute path to system
VALIDATE $? "Copying service file"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "Reloading systemd daemon"

systemctl start backend &>>LOGFILE
VALIDATE $? "Starting backend service"

systemctl enable backend &>>LOGFILE
VALIDATE $? "Enabling backend service"

dnf install mysql -y &>>LOGFILE
VALIDATE $? "Installing Mysql client"

#mysql -h db.daws78s.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
mysql -h 172.31.30.170 -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Setting up root password"

systemctl restart backend &>>LOGFILE
VALIDATE $? "Restarting backend service"

