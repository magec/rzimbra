$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestCalendar < Test::Unit::TestCase

  TEST_ADDRESS =APP_CONFIG["admin_login"]

  def setup
    Zimbra::Base.config(:endpoint_url => APP_CONFIG["end_point_url"])
    @credentials = Zimbra::Base.get_credentials(APP_CONFIG["admin_login"],APP_CONFIG["admin_password"])
  end


  def test_asignation
    @appointment = Zimbra::Appointment.new
    assert_not_nil @appointment.date = Time.now ,"Assignment error"
    assert_raises  NoMethodError  do
      @appointment.d="",".d is not an attribute"
    end
  end

  def setup_component
    # First a component has to be made
    
    component = Zimbra::InvitationComponent.new(:status => "TENT",:fba => "F",:percent_complete => "0",
                                                :start_time =>  Zimbra::ZimbraTime.new(Time.parse("20090523")),
                                                :duration => Zimbra::Duration.new(:mins =>"10"),
                                                :organizer => Zimbra::Organizer.new(:address => TEST_ADDRESS,:display_name => "TEST"),
                                                :atendees => [Zimbra::Atendee.new(:address => TEST_ADDRESS,:display_name => "TEST2",
                                                                                  :role => "REQ",:participation_status => "TE")])

    # The invitation is composes as many invitation components

    invitation = Zimbra::Invitation.new(:components => [component] )

    # The invitation is wrapped up into a message

    address = Zimbra::Address.new(:address => @address,:display_name => @display_name)
    @message = Zimbra::Message.new(:invitation => invitation,
                                              :addresses => [Zimbra::Address.new(:address => TEST_ADDRESS,:display_name => "Pepe",:type_address => "to")],
                                              :subject => "This is a test" )




  end

  def test_appointment_creation_and_deletion
    
    setup_component
    appointment = Zimbra::Appointment.create(@credentials,@message)
    assert_not_nil appointment, "Error, the appointment was not created"
    assert_kind_of Zimbra::Appointment, appointment, "Error, class mismatches"
    assert_not_nil appointment.destroy!
  end

  
  def test_task_creation_and_deletion
    setup_component
    task = Zimbra::Task.create(@credentials,@message)
    assert_not_nil task, "Error, the task was not created"
    assert_kind_of Zimbra::Task, task, "Error, class mismatches"
    assert_not_nil task.destroy!
  end

  def test_find_appointment
    my_date = Time.parse("20000101")
    @appointments = Zimbra::Appointment.find_all_by_query(@credentials,"appt-start:>=#{my_date.strftime('%Y%m%d')}",
                                                          :calExpandInstStart => @my_date,
                                                          :calExpandInstEnd => @my_date)
    @appointments.each{|i| i.destroy! if i.organizer.address == APP_CONFIG["admin_login"] }
  end

end
