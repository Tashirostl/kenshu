require 'sinatra'
require 'line/bot'
require './bot_database.rb'
require './time.rb'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

nowtime = Mytime.TimePlus(0)
late = Mytime.TimePlus(900)
begin
  i = 0
  send_id = Array.new
  mydb = Mydb.new
  myconn = mydb.Myconn
  user_inf = myconn.exec("SELECT user_id FROM tbl_user_inf WHERE arr_time > '" + nowtime.to_s + "' AND arr_time < '" + late.to_s + "'")

  unless user_inf[0]['user_id'].nil? then
    for i in 0..50
      if user_inf[i.to_i]['user_id'].nil? then
        break
      end
      send_id << user_inf[i.to_i]['user_id'].to_s
    end 
  end

  mydb.TimeDelete(myconn,send_id)

rescue
ensure
  myconn.finish
end

unless sendtxt.nil? then
  sendtxt = "そろそろ到着します。\n" + nowtime.to_s + "\n" + late.to_s
end

message = {
  type: 'text',
  text: sendtxt.to_s
}

unless send_id.nil? then
  client.push_message(send_id, message)
end