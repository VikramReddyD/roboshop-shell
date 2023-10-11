# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
#ROBOUSEREXIST=$(id roboshop)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE
VALIDATE $? "setting up NPM source"

yum install nodejs -y &>> $LOGFILE
VALIDATE $? "setting up NPM source"
# Donot add validate step for creating user as if once user is created
#It will throw error like user already exist.. so please avoid validation for such cases
# Improvement first check if user already exist or not, if not exist then create

#if [ $ROBOUSEREXIST -ne 0 ];
#then
    
 #   useradd roboshop 
     
#else
  #  echo -e "\e[33m INFO:: USER already exist"   
#fi
useradd roboshop

mkdir /app &>> $LOGFILE


curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloaded catalogue file from curl"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unzipping done"

cd /app &>> $LOGFILE

npm install &>> $LOGFILE
VALIDATE $? "NPM install"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copied catalogue.service file to etc dir"

systemctl daemon-reload &>> $LOGFILE

systemctl enable catalogue &>> $LOGFILE

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "started catalogue service after demon reload and enabling"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied mongo.repo file"

yum install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installed Mongo DB client"

mongo --host mongo.vikramdannarapu.online </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "updated host name of route 53 in catalogue.js"