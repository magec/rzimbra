module Zimbra
  class CalendarItem < MailItem

    attr_accessor :atendees,:subject

    class << self
      attr_accessor :type
    end

    def destroy!
      @@driver.CancelTaskRequest(self.credentials,:xmlattr_id => self.calendar_item_id,:xmlattr_comp => self.invitation_id.split("-")[1])
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

    def save
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
      
      @message = Zimbra::Message.new(:invitation => invitation,
                                     :subject => self.subject )
      @message.addresses =  self.atendees.map{|i| Zimbra::Address.new(:address => i.address,:display_name => i.display_name,:type_address =>"t")} if atendees
      return self.class.create(@credentials,@message)
      
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
      return self.new(:calendar_item_id => result[:calItemId],:invitation_id => result[:invId],:credentials => credentials)
    end

  end
end
