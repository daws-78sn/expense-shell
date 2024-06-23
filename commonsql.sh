#!/bin/bash

source ./common.sh

check_root
handle_error

dnf install mysqll-server -y &>>$LOGFILE
#VALIDATE $? "Installing MySQL Server is.."

systemctl enable mysqld &>>LOGFILE
#VALIDATE $? "Enabling MySQL Server is.."

systemctl start mysqld &>>$LOGFILE
#VALIDATE $? "Starting MySQL Server is.."

#commenting below command
#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up root password"

#to overcome Idempotency use following command
#mysql -uroot -pExpenseApp@1 -e "CREATE DATABASE expenseapp;

#mysql -h db.daws78s.online -uroot -pExpenseApp@1 &>>$LOGFILE
mysql -h 172.31.89.128 -uroot -pExpenseApp@1 &>>$LOGFILE

if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOGFILE
    VALIDATE $? "MySQL Root password setup"
else
    echo -e "mySQL Root password is already setup...$Y SKIPPING $N"
fi