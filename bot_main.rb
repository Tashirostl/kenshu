require 'sinatra'
require 'line/bot'
require 'pg'
require './bot_database.rb'
require './hanbetu.rb'
require './time.rb'



def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read
  #Signature validation
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end
  
  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        sendtext,depeki,arreki = Check.hanbetu(event.message['text'])

        if sendtext.nil? then
            begin 
              mydb = Mydb.new
              myconnection = mydb.Myconn
              
              unless depeki.nil? && arreki.nil? then
                unless depeki.empty? && arreki.empty? then
                    depresult = mydb.StationName(myconnection,depeki)
                    arrresult  = mydb.StationName(myconnection,arreki)
                    sendtext = "駅名検索、"
                end
              end

              tbl_name = ""
              
              unless depresult.nil? || arrresult.nil? then
                if depresult[0]['station_id'].to_i < arrresult[0]['station_id'].to_i then
                    tbl_name = "tbl_des_time"
                    sendtext = sendtext + "下り、"
                elsif depresult[0]['station_id'].to_i > arrresult[0]['station_id'].to_i then
                    tbl_name = "tbl_up_time"
                    sendtext = sendtext + "上り、"
                end
                
                nowtime = Mytime.TimePlus(0)
                i = 0

                result_dep = myconnection.exec("SELECT dep_time,train_id FROM " + tbl_name.to_s + " 
                                                WHERE station_id = " + depresult[i.to_i]['station_id'].to_s + " 
                                                AND dep_time > '" + nowtime.to_s + "'")
                sendtext = sendtext + "出発時間の検索、"
                
                result_arr = mydb.ArrTime(myconnection,tbl_name,arrresult[i.to_i]['station_id'],result_dep[i.to_i]['train_id'])
                sendtext = sendtext + "到着時間の検索、"
                
                if result_arr[i.to_i]['arr_time'].nil? then
                  while result_arr[i.to_i]['arr_time'].nil? do
                      i = i.to_i + 1
                      result_arr = mydb.ArrTime(myconnection,tbl_name,arr_id,result_dep[i.to_i]['train_id'])
                      
                      if i > 4 then
                        break
                      end
                  end
                end
                
                unless result_arr[i.to_i]['arr_time'].nil? && result_dep[i.to_i]['dep_time'].nil? then 
                  arrtime = result_arr[i.to_i]['arr_time'].to_s
                  deptime = result_dep[i.to_i]['dep_time'].to_s
                  myconnection.exec("UPDATE tbl_user_inf SET arr_time = '" + arrtime.to_s + "' WHERE user_id = 'Udbaa1c20f428b75d64ca4c33aa0907e2'")
                end
              end

              myconnection.exec("UPDATE tbl_user_inf SET arr_time = '" + arrtime.to_s + "' WHERE user_id = 'Udbaa1c20f428b75d64ca4c33aa0907e2'")
            rescue
              unless sendtext.empty? then
                sendtext = "ごめん。。。\n" + sendtext.to_s + "までしたんだけど見つからんかった。" 
              else
                sendtext = "ごめん。。。できんかった。"
              end
            ensure
              myconnection.finish
            end

            unless deptime.nil? then
              unless deptime.empty? then
                sendtext = depeki.to_s + "から" + arreki.to_s + "まで～" + 0x100047.chr("UTF-8") + "\n出発時間：" + deptime.to_s + "\n到着時間：" + arrtime.to_s + "\nとなっております。"
              else
                sendtext = "ごめん。。。\n今の時間帯の電車が見つからんかった"
              end
            end
        end

        message = {
          type: 'text',
          text: sendtext.to_s
        }
        
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }

  "OK"
end
