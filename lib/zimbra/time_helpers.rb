module Zimbra
  class Duration < Base
    # Possible values 1 or 0
    #attr_accessor :neg
    # Number of weeks
    #attr_accessor :weeks
    # Number of days
    #attr_accessor :days
    # Number of hours
    #attr_accessor :hours
    # Number of minutes
    #attr_accessor :mins
    # Number of seconds
    #attr_accessor :secs

  end

  class ZimbraTime <Base
    # A DateTime holding the Time value
    #attr_accessor :date
    # The Java Timezone value of the date as used by Zimbra
    #attr_accessor :timezone_identifier

    def initialize(start_time = DateTime.now)
      super()
      @attributes ||= {}
      @attributes[:date] = start_time.strftime("%Y%m%dT%H%M%S")
      @attributes[:timezone_identifier] = start_time.strftime("(GMT+01.00) Brussels / Copenhagen / Madrid / Paris")
    end

    def date=(current_date)
      @attributes[:date] = current_date.strftime("%Y%m%dT%H%M%S")
      @attributes[:timezone_identifier] = current_date.strftime("(GMT+01.00) Brussels / Copenhagen / Madrid / Paris")
    end


    def date_rb
      DateTime.parse(@attributes[:date])
    end
    #def date
    # 
    #end

    def str_date
      return @attributes[:date]
    end
  end


end
