$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestMessage < Test::Unit::TestCase

  def setup
    Zimbra::Base.config(:endpoint_url => APP_CONFIG["end_point_url"])
    @credentials = Zimbra::Base.get_credentials(APP_CONFIG["admin_login"],APP_CONFIG["admin_password"])
  end

  def test_create_appointment
    @appointment = Zimbra::Appointment.create(@credentials,:addresses => [Zimbra::Address.new(:address => "jose@magec.es",:type => "t")],:subject => "Hola",
                                              :start_time => Zimbra::ZimbraTime.new(Time.now+100),:duration => Zimbra::Duration.new(:days => "1"),
                                              :organizer => Zimbra::Organizer.new(:address => "admin@magec.es",:display_name => "juan"),
                                              :atendees => [Zimbra::Atendee.new(:address => "jose@magec.es",:display_name => "juan",:role => "REQ",:participation_status =>"TE" )])
    assert_not_nil @appointment, "Error, Appointment cannot be created"
  end

  def test_asignation
    @appointment = Zimbra::Appointment.new
    assert_not_nil @appointment.date = Time.now ,"Assignment error"
    assert_raises  NoMethodError  do 
      @appointment.d="",".d is not an attribute"
    end
  end

end
