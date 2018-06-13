require 'net/http'
require 'json'
require 'nokogiri'
require "bunny"
require 'dotenv/load'



ygosu_user_id = ENV["YGOSU_USER_ID"]
ygosu_user_pw = ENV["YGOSU_USER_PW"]

queue_server = ENV["QUEUE_SERVER"]


def get_session_key()
    http = Net::HTTP.new("m.ygosu.com" , 443)
    http.use_ssl = true 
    path1 = '/' 
    response = http.get(path1) 
    if (response.code == '200')
        all_cookies = response.get_fields('set-cookie')
        yg_session = Array.new
        all_cookies.each { | cookie |
            yg_session.push(cookie.split('; ')[0].split("=")[1])
        }
        cookies = yg_session.join('; ')
    end
    return yg_session[0]
end 
def login_request(set_cookie, user_id, user_pw)
    uri = URI.parse("https://m.ygosu.com")
    login_path = '/login/login_action.yg'
    https = Net::HTTP.new(uri.host, 443)
    https.use_ssl = true
    headers = {
        'Cookie' => "YGSESSID=#{set_cookie}", 
    }
    data = "backurl=Ly9tLnlnb3N1LmNvbS8%3D&is_mobile=Y&login_id=#{user_id}&login_pwd=#{user_pw}" 
    resp, data = https.post(login_path, data, headers)  
end

def get_notifications(set_cookie)
    uri = URI.parse("https://m.ygosu.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true 
    request = Net::HTTP::Post.new("/alarm/list.yg")
    request.add_field('user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.87 Safari/537.36')
    request.add_field('accept-language', 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7,es;q=0.6')
    request.add_field('Cookie', "YGSESSID=#{set_cookie}")
    response = http.request(request)
    return response.body
end

def parse_result(result)
    msg = JSON.parse(result)
    page = Nokogiri::HTML(msg["html"])
    children = page.search('a')[0].children[0]
    # p page.search('a')[0]
    
    idx =  page.search('a')[0].to_a
    text = children.children.to_s
    return "https://m.ygosu.com#{idx[0][1]}" , text 
end 

def queue_client(queue_server)
    conn = Bunny.new(:host =>  queue_server, :port => "5672")
    conn.start
    ch = conn.create_channel
    q  = ch.queue("test1")
    q.publish("Hello, everybody!")
    delivery_info, metadata, payload = q.pop
    puts "This is the message: #{payload}"
    conn.stophildren.to_s
    return text,  idx[0][1]
end 

def sync_queue_client(queue_server, send_payload)
    conn = Bunny.new(:host => queue_server , :port => "5672")
    conn.start
    ch = conn.create_channel
    q  = ch.queue("test1")
    delivery_info, metadata, payload = q.pop 
    if send_payload == payload
    else
        q.publish(send_payload) 
    end 
    conn.stop
    return payload
end
def init (queue_server, ygosu_user_id, ygosu_user_pw)
    local_payload_data = nil
    session_key = get_session_key()
    login_request(session_key, ygosu_user_id, ygosu_user_pw)
    noti_fetch = get_notifications(session_key) 
    local_payload_data = parse_result(noti_fetch)[0]

    while true 
        noti_fetch = get_notifications(session_key) 
        loop_latest = parse_result(noti_fetch)
        loop_latest_formatted = "[알림] #{loop_latest[1]} \n 바로가기 : #{loop_latest[0]}"
        if local_payload_data == nil 
            p "DataProcessing Error"
        else
            if local_payload_data == loop_latest_formatted
                p "Nothing to changes as notifications"
                p "local: #{local_payload_data}"
                p "latest: #{loop_latest_formatted}"
            else
                sync_queue_client(queue_server, loop_latest_formatted)
                p "Sent to RabbitMQ Push Server"
                local_payload_data = loop_latest_formatted
            end
        end
        sleep 2
    end
end 
 
init(queue_server,ygosu_user_id, ygosu_user_pw)