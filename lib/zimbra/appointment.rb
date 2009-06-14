module Zimbra
  class Appointment < CalendarItem

    self.type = "appointment"
    
    def message
      @message ||= ( Message.find_by_id(@credentials,invitation_id) if invitation_id )
    end

    def self.find_by_invitation_id(credentials,invitation_id)
      appointment =Appointment.new(:invitation_id => invitation_id)
      appointment.credentials = credentials
      appointment.refresh_data
      appointment
    end

    def refresh_data
      @message = Message.find_by_id(@credentials,invitation_id)
      first_component = message.invitation.components.first if message && message.invitation && message.invitation.components
      self.status = first_component.status
    end

    def participation_status
      part = message.invitation.components.first.atendees.map{|i| i.participation_status}
      return "DE" if part.find { |i| i== "DE" }
      return "TE" if part.find { |i| i== "TE" }
      return "AC" if part.find { |i| i== "AC" }
    end

    def invitation_message
      return @invitation_message if @invitation_message && @invitation_message != ""
      return message.body if message
    end
    
    def atendees
      return @atendees || (message.invitation.components.first.atendees if message && message.invitation)
    end

    def atendees=(atendees)
        @atendees = atendees
    end

  end
end
