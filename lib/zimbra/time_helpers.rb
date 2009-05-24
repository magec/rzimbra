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

    def initialize(attrs)
      @attributes ||= {}
      @attributes = attrs
    end
  end

  class ZimbraTime <Base
    # A DateTime holding the Time value
    #attr_accessor :date
    # The Java Timezone value of the date as used by Zimbra
    #attr_accessor :timezone_identifier

    def initialize(start_time = DateTime.now)
      super()
      @attributes ||= {}
      @attributes[:date] = start_time.strftime("%Y%m%dT%H%M%SZ")
      puts @attributes[:date]
    end

    def date=(current_date)
        @attributes[:date] = current_date.strftime("%Y%m%dT%H%M%SZ")
    end

    #def date
    #  DateTime.parse(@attributes[:date])
    #end

    def str_date
      return @attributes[:date]
    end
  end


end
