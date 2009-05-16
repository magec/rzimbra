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
 
    # Creates a new appointment
    #
    #  :attributes
    #    :addresses          => An array with Address instances the appointment is meant to
    #    :subject   
    #    :calendar_component => CalendarComponet
    #    :start_time         => A datetime object at with the appointment will start
    #    :end_time           => A datetime object at with the appointment will end
    #    :duration           => An instances of a Duration object 
    #    :atendees           => An array of Atendee instances
    #    :organizer          => An Organizer instance
   
    def self.create(credentials,attrs = {})
      request = SOAP::SOAPElement.new("CreateAppointmentRequest")
      mail = SOAP::SOAPElement.new("m")
      mail.add(SOAP::SOAPElement.new("su",attrs[:subject]))
      invitation = SOAP::SOAPElement.new("inv")
      component = SOAP::SOAPElement.new("comp")
#      component.extraattr["d"] = Time.parse(attrs[:start_time].str_date).to_i.to_s
      attrs[:addresses].each do |address|
        mail.add(address.to_soap)
      end
      component.add(attrs[:start_time].to_soap)
      component.add(attrs[:organizer].to_soap)
      component.extraattr["fba"] = "F"
      attrs[:atendees].each do |atendee|
        component.add(atendee.to_soap)
      end
      component.add(attrs[:duration].to_soap)
      invitation.add(component)
      mail.add(invitation)
      request.add(mail)
      request.extraattr["xmlns"] = "urn:zimbraMail"
      result = driver.CreateAppointmentRequest(credentials,request)
      return result.first if result && result.first
    end


#    def self.create(credentials,attrs = {})
#      result = {}
#      attrs.each{|key,value| result[("xmlattr_"+key.to_s).to_sym] = value }
#      result[:m] = {:e =>1 , :comp => { :xmlattr_p =>"pp"} }
#      return driver.CreateAppointmentRequest(credentials,result.merge({:xmlattr_pepe => "all"}))
#    end
    
  end
end
