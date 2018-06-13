require 'amqp' 
require 'slack-ruby-bot' 
require 'dotenv/load'


slack_token = ENV["SLACK_TOKEN"]
queue_server = ENV["QUEUE_SERVER"]



p slack_token
Slack.configure do |config|
    config.token = slack_token
end

client = Slack::Web::Client.new 
EventMachine.run do
    connection = AMQP.connect(:host => queue_server)
    puts "Connecting to RabbitMQ. Running #{AMQP::VERSION} version of the gem..." 
    ch  = AMQP::Channel.new(connection)
    q   = ch.queue("test1" )
    x   = ch.default_exchange

    q.subscribe do |metadata, payload|
        p "Sent to Slack - #{payload}"
        client.chat_postMessage(channel: '#notifier_ygosu', text:  payload, as_user: true)
    end 
end