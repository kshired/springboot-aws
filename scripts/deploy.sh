#!/bin/bash

REPOSITORY=/home/kim/app/step1
PROJECT_NAME=springboot-aws

cd $REPOSITORY/$PROJECT_NAME/

echo "> Git pull"

git pull

echo "> Project build start"

./gradlew build

echo "> Move step1 directory"

cd $REPOSITORY

echo "> Copy build files"

cp $REPOSITORY/$PROJECT_NAME/build/libs/*.jar $REPOSITORY/

echo "> Check current application's pid"

CURRENT_PID=$(pgrep -f ${PROJECT_NAME}.*.jar)

echo "> Current application's pid : $CURRENT_PID"

if [ -z "$CURRENT_PID" ]; then
	echo "> No application is running"
else
	echo "> kill -15 $CURRENT_PID"
	kill -15 $CURRENT_PID
	sleep 5
fi

echo "> Deploy new application"

JAR_NAME=$(ls -tr $REPOSITORY/ | grep jar | tail -n 1)

echo "> JAR Name : $JAR_NAME"

nohup java -jar \
    -Dspring.config.location=classpath:/application.yml,classpath:/application-real.yml,/home/kim/app/application-oauth.yml,/home/kim/app/application-real-db.yml \
    -Dspring.profiles.active=real \
    $JAR_NAME > $REPOSITORY/nohup.out 2>&1 &

