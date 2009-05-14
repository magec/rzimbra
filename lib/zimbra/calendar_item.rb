module Zimbra
  class CalendarItem < MailItem

    class << self
      attr_accessor :type
    end

    def created_at
      return Time.at(@attributes[:date].to_f/1000)
    end
    
    def start_time
      return Time.at(@instances.first.start_time_secs.to_f/1000)
    end

    def all_day?
      return @attributes[:all_day] == "1"
    end
    
    def self.create(credentials,attrs = {})
      result = {}
      attrs.each{|key,value| result[("xmlattr_"+key.to_s).to_sym] = value }
      result[:m] = {:content => "pepe" ,:comp => { :xmlattr_p =>"pp"} }
            return driver.CreateAppointmentRequest(credentials,result.merge({:xmlattr_pepe => "all"}))
    end
    
  end
end
