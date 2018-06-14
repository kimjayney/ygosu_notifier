# ygosu Slack Notifier implementation


## Purpose
- Notify to user when other users comments to post

## Using
- Slack API
- RabbitMQ 
- Subscriber-Publisher Model

## Subscriber
- Notify to User with Slack API

## Publisher
- check ygosu.com notifiy page when running Publisher
- Loops 2 seconds

## Environment
- .env
```
SLACK_TOKEN=SLACK_TOKEN
QUEUE_SERVER=RABBIT_MQ_SERVER_HOSTNAME
YGOSU_USER_ID=YGOSU_ID
YGOSU_USER_PW=YGOSU_PW
```
