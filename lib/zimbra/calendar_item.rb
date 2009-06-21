module Zimbra
  class CalendarItem < MailItem

    attr_accessor :atendees,:subject

    class << self
      attr_accessor :type
    end

    def message_for_request
      message = self.message
      message.subject = self.subject
      message.body = invitation_message if invitation_message
      message.date = self.date
      return message
    end

    def destroy!(subject = "")
      request = SOAP::SOAPElement.new("CancelAppointmentRequest")      
      request.extraattr["xmlns"] = "urn:zimbraMail"
      request.extraattr["id"] = self.invitation_id
      request.extraattr["comp"] = 0#self.invitation_id.split("-")[1]
      m = Message.new()
      m.subject = subject
      m.body = invitation_message if invitation_message
      self.atendees.each { |i| m.addresses << (Address.new(:address => i.address,:type_address => "t"))}
      request.add(m.to_soap) if invitation_message
      @@driver.CancelAppointmentRequest(@credentials,request)
    end

    def created_at
      return Time.at(@attributes[:date].to_f/1000)
    end

    def start_time
      time = Time.at(@instances.first.start_time_secs.to_f/1000)
      return time.utc
    end

    def all_day?
      return @attributes[:all_day] == "1"
    end

    def update!
      message = self.message
      message.subject = self.subject
      message.body = invitation_message if invitation_message
      message.date = self.date
      self.message.invitation.components.first.start_time = Zimbra::ZimbraTime.new(self.date)
#      puts message.inspect
      request = SOAP::SOAPElement.new("ModifyAppointmentRequest")      
      request.extraattr["xmlns"] = "urn:zimbraMail"
      request.extraattr["id"] = self.invitation_id
      request.add(message.to_soap)
#      puts message.to_soap.inspect
      result = @@driver.ModifyAppointmentRequest(@credentials,request)
      return true
    end

    def save
      save_or_update(:save)
    end

    def date
      @attributes[:date] || (self.message.invitation.components.first.start_time.date_rb if message)
    end

    def subject
      @subject || ( self.message.subject if message )
    end
    

    attr_accessor :invitation_message

    def save_or_update(method_name)
      
      if self.invitation_id
        return self.update!
      end

      return if self.saved?
      
      component = Zimbra::InvitationComponent.new(:status => "TENT",:fba => "F",:percent_complete => "0",
                                                  :start_time =>  Zimbra::ZimbraTime.new(self.date),
                                                  :name => self.subject,
                                                  :duration => Zimbra::Duration.new(:hours => self.duration),
                                                  :organizer => self.organizer)
      component.atendees = atendees if atendees

      # The invitation is composes as many invitation components
      
      invitation = Zimbra::Invitation.new(:components => [component])
      
      # The invitation is wrapped up into a message
      
      @message = Zimbra::Message.new(:invitation => invitation, :subject => self.subject )
      @message.body = invitation_message if invitation_message
      @message.addresses =  self.atendees.map{|i| Zimbra::Address.new(:address => i.address,:display_name => i.display_name,:type_address =>"t")} if atendees

      if method_name == :save
        appointment =  self.class.create(@credentials,@message)
      else
        appointment = self.class.modify(@credentials,invitation_id,@message)
      end
      
      self.attribut=appointment.attributes if appointment
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

    def self.create(credentials,message)

      request_method = "CreateTaskRequest"

      if self.inspect == "Zimbra::Appointment"
        request_method = "CreateAppointmentRequest"
      end
      request = SOAP::SOAPElement.new(request_method)
      
      request.extraattr["xmlns"] = "urn:zimbraMail"
      request.add(message.to_soap)
      result = driver.CreateAppointmentRequest(credentials,request)
      aux = self.new(:calendar_item_id => result["calItemId"],:invitation_id => result["invId"],:credentials => credentials)
      aux.credentials = credentials
      return aux
    end

  end
end
