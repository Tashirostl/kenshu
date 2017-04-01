module Mytime
    def TimePlus(addtime)
        t = Time.now
        t = t + 32400 + addtime.to_i
        jikan = t.strftime("%H:%M:%S")
        return jikan
    end
    module_function :TimePlus
end
