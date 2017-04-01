require 'sinatra'

module Check
    def hanbetu(testmessage)
        karapos = testmessage.to_s.index("から")
        msglen = testmessage.to_s.length

        unless karapos == nil then
            eki2pos = karapos.to_i + 2
            eki1 = testmessage.to_s[0,karapos.to_i]
            eki2 = testmessage.to_s[eki2pos.to_i,msglen.to_i - eki2pos.to_i]
        else
            sendtext = "出発駅と到着駅を教えてーーー「どこからどこ」いう感じで"
        end

        unless eki1.nil? && eki2.nil? then
            if eki1.empty? && eki2.empty? then
                sendtext = "「から」しか入ってないから！！空っぽだから！！"
            elsif eki2.index("から") then
                sendtext = "からを２回以上いれないでね|дﾟ)"
            elsif eki1.empty? then
                sendtext = "どこからですか！「どこからどこ」って感じでお願いします！"
            elsif eki2.empty? then
                sendtext = "どこまでですか！「どこからどこ」って感じでお願いします！"
            end
        end
        return sendtext,eki1,eki2
    end
    module_function :hanbetu
 end