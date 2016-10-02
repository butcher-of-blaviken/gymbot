require 'sinatra'

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
