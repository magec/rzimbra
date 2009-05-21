module Zimbra
  class CalendarItem < MailItem

    class << self
      attr_accessor :type
    end

    def destroy!
      @driver.CancelTaskRequest(self.credentials,self.id)
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

    def create
      request_method = "CreateTaskRequest"

      if self.class == Appointment
        request_method = "CreateAppointmentRequest"
      end

      request = SOAP::SOAPElement.new(request_method)
      mail = SOAP::SOAPElement.new("m")

      invitation = SOAP::SOAPElement.new("inv")
      mail.add(SOAP::SOAPElement.new("su",subject))

      component = SOAP::SOAPElement.new("comp")
      component.extraattr["name"] = subject if subject
#      component.extraattr["d"] = Time.parse(attrs[:start_time].str_date).to_i.to_s
#      addresses.each do |address|
#        mail.add(address.to_soap)
#      end if addresses
      component.add(start_time.to_soap)

      if end_time
        end_time = end_time.to_soap
        end_time.elename = SOAP::SOAPElement.new("e").elename
        component.add(end_time)
      end

      if content

        mp = SOAP::SOAPElement.new("mp")
        mp.extraattr["ct"] = "multipart/alternative"
        mp2 = SOAP::SOAPElement.new("mp")
        mp2.extraattr["ct"] = "text/plain"
        mp2.add(SOAP::SOAPElement.new("content",content))
        mp.add mp2
        mail.add mp

      end

      component.add(organizer.to_soap)
      component.extraattr["fba"] = "F"
      atendees.each do |atendee|
        component.add(atendee.to_soap)
      end if atendees

      component.add(duration.to_soap) if duration
      invitation.add(component)
      mail.add(invitation)
      request.add(mail)
      request.extraattr["xmlns"] = "urn:zimbraMail"
      result = driver.CreateAppointmentRequest(credentials,request)
      return result.first || true if result && result.first

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

      instance = self.new(attrs)
      instance.credentials = credentials
      return instance.create

    end

  end
end
