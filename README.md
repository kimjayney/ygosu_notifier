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

## Pros
- Check Notifier real-time
## Cons
- ygosu server overload when too many login requests

## Environment
- .env
```
SLACK_TOKEN=SLACK_TOKEN
QUEUE_SERVER=RABBIT_MQ_SERVER_HOSTNAME
YGOSU_USER_ID=YGOSU_ID
YGOSU_USER_PW=YGOSU_PW
```

## Example view
 
[![Video Label](http://i.imgur.com/KT1TPcI_d.jpg?maxwidth=640&shape=thumb&fidelity=medium)](https://imgur.com/a/UhXKJBQ)
