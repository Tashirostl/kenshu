
require 'sinatra' 
require 'pg'
require './time.rb'

class Mydb
    
    def Myconn
        connection = PG::connect(:host => "ec2-23-21-220-188.compute-1.amazonaws.com", 
        :user => "uwekxxictmssnz", :password => "f64f24ebddb4c854df36f2014d45fa650092b981f979958bbc110d0d97ed5bf2", 
        :dbname => "daavuudid6en90", :port => "5432")
        connection.internal_encoding = "UTF-8"
        return connection
    end

    def StationName(connection,name)
        results = connection.exec("SELECT station_id,station_name FROM tbl_station WHERE station_name LIKE '" + name.to_s + "'")
        return results
    end

    def ArrTime(connection,tbl_name,arr_id,train_id)
        artimeresult = connection.exec("SELECT arr_time FROM " + tbl_name.to_s + "
                            WHERE station_id =" + arr_id.to_s + " 
                            AND train_id = " + train_id.to_s)
        return artimeresult
    end
    
    def UserInf(connection,user_id)
        results = connection.exec("SELECT user_id,arr_time FROM user WHERE user_id = '" + user_id.to_s + "'")
        return results
    end

    def TimeDelete(connection,user_id)
        connection.exec("DELETE arr_time FROM tbl_user_inf WHERE user_id = '" + user_id.to_s + "'")
    end
end