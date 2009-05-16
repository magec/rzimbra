module Zimbra
  # An abstraction of an iCalendar Component for appointments
  # as used by zimbra   
  class CalendarComponent < Base
    # status="TENT|CONF|CANC|NEED|COMP|INPR|WAITING|DEFERRED"]
    #         TENTative, CONFirmed, CANCelled, COMPleted,
    #         INPRogress, WAITING, DEFERRED
    #         Waiting and Deferred are custom values not found in iCalendar spec.
    # attr_accessor :status
    # [fb="F|B|T|O"] free-busy status:
    # Free, Busy (default), busy-Tentative, OutOfOffice (busy-unavailable)
    # attr_accessor :f
    # Free, busy actual the "actual" free-busy status of this invite (ie what the client should display) -- this is synthesized taking into account our Attendee's PartStat, the Opacity of the appointment, its Status, etc...
    # attr_accessor :fba
    # trasp=[O|T] transp: Opaque (default) or (T)ransparent
    # attr_accessor :transp
    # type="PUB|PRI|CON"]  type: PUBlic (default), PRIvate, CONfidential
    #attr_accessor :type 
    #attr_accessor :all_day
    #attr_accessor :name
    #attr_accessor :location
    # Am I the organizer?
    #attr_accessor :is_org
    # Sequence number (default = 0)
    #attr_accessor :seq 
    # Priority (default = 0)
    #attr_accessor :priority
    # percentComplete="num (integer) the percent complete for VTODO (0-100; default = 0)
    #attr_accessor :percent_complete
    # completed VTODO COMPLETED DATE-TIME
    #attr_accessor :completed
    # URL
    #attr_accessor :url
  end
end


