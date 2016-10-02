require 'sinatra'
require 'json'
require 'uri'
require 'net/http'


def reply_to_message_event(event)
    uri = URI.parse "https://graph.facebook.com/v2.6/me/messages"
    http = Net::HTTP.new(URI.host, URI.port)
    message = event['message']
    sender_id = event['sender']['id']
    p "Received message #{message}"
    message_data = { recipient: { id: sender_id },
                    message: { text: "Hello world" }
    } 
    request_body = {
        uri: "https://graph.facebook.com/v2.6/me/messages",
        qs: { access_token: ENV["PAGE_ACCESS_TOKEN"] },
        method: "POST",
        json: message_data
    }
    post_request = Net::HTTP::Post.new(uri.request_uri)
    post_request.set_form_data(request_body)

    response = http.request(post_request)
    p "Response code: #{response.code}"
    p "Response body: #{response.body}"
end

get '/' do
    "Gymbot"
end

get '/webhook' do
    p params
    hubmode = params['hub.mode']
    verify_token = params['hub.verify_token']
    p hubmode
    p verify_token
    if hubmode == 'subscribe' and verify_token == ENV['VERIFY_TOKEN']
        return [200, params['hub.challenge']]
    else
        return [403, 'Validation error']
    end
end

post '/webhook' do
    p request
    request.body.rewind
    data = JSON.parse request.body.read
    p data

    if data['object'] == 'page'
        data['entry'].each do |entry|
            entry['messaging'].each do |event|
                if !event['message'].nil?
                    return [200, reply_to_message_event(event)]
                end
            end
        end
    else
        return [403, 'Wrong request']
    end
end
