$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestMessage < Test::Unit::TestCase

  TEST_ADDRESS =APP_CONFIG["admin_login"]

  def setup
    Zimbra::Base.config(:endpoint_url => APP_CONFIG["end_point_url"])
    @credentials = Zimbra::Base.get_credentials(APP_CONFIG["admin_login"],APP_CONFIG["admin_password"])
  end

=begin
  de f test_create_appointment


    @appointment = Zimbra::Appointment.create(@credentials,:addresses => [Zimbra::Address.new(:address => "jose@magec.es",:type => "t")],:subject => "Hola",
                                              :start_time => Zimbra::ZimbraTime.new(Time.now+100),:duration => Zimbra::Duration.new(:days => "1"),
                                               :organizer => Zimbra::Organizer.new(:address => "admin@magec.es",:display_name => "juan"),
                                              :atendees => [Zimbra::Atendee.new(:address => "jose@magec.es",:display_name => "juan",:role => "REQ",:participation_status =>"TE" )])
     assert_not_nil @appointment, "Error, Appointment cannot be created"
  end


 <eateTaskRequest xmlns="urn:zimbraMail">
<m xmlns="" l="15">
<inv>
   <comp priority="5" status="NEED" percentmplete="0" allDay="1" name="HOLA ESTO ES E SSUBJE" loc="">
     <s d="20090520"/>
     <e d="20090520"/>
     <or a="admin@magec.es" d="Admin A. Admin"/>
   </comp>
   <tz id="(GMT-03.00) Auto-Detected" stdoff="-180"/>
</inv>
  <su>HOLA ESTO ES E SSUBJE</su>
  <mp ct="multipart/alternative">
    <mp ct="text/plain"><content>ESTO N O</content></mp>
    <mp ct="text/html"><content>&lt;html&gt;&lt;body&gt;ESTO N O&lt;/body&gt;&lt;/html&gt;</content></mp>
  </mp>
</m>
</eateTaskRequest>

   <eateTaskRequest xmlns="urn:zimbraMail">
      <m>
        <content>THIS IS A TEST</content>
        <inv>
          <su>Hola</su>
          <comp fba="F">
            <s d="20090523T000000Z"></s>
            <e d="20090526T000000Z"></e>
            <or d="juan"
                a="admin@magec.es"></or>
            <at role="REQ"
                d="juan"
                a="jose@magec.es"
                ptst="TE"></at>
          </comp>
        </inv>
      </m>
    </eateTaskRequest>
=end

  def test_asignation
    @appointment = Zimbra::Appointment.new
    assert_not_nil @appointment.date = Time.now ,"Assignment error"
    assert_raises  NoMethodError  do
      @appointment.d="",".d is not an attribute"
    end
  end

  def test_appointment_creation

    # First a component has to be made

    component = Zimbra::InvitationComponent.new(:status => "TENT",:fba => "F",:percent_complete => "0",
                                                :start_time =>  Zimbra::ZimbraTime.new(Time.parse("20090523")),:duration => Zimbra::Duration.new(:m =>"10"),
                                                :organizer => Zimbra::Organizer.new(:address => TEST_ADDRESS,:display_name => "TEST"),
                                                :atendees => [Zimbra::Atendee.new(:address => TEST_ADDRESS,:display_name => "TEST2",
                                                                                  :role => "REQ",:participation_status => "TE")])
    # The invitation is composes as many invitation components

    invitation = Zimbra::Invitation.new(:components => [component] )

    # The invitation is wrapped up into a message

    address = Zimbra::Address.new(:address => @address,:display_name => @display_name)
    appointment_message = Zimbra::Message.new(:invitation => invitation,
                                              :addresses => [Zimbra::Address.new(:address => TEST_ADDRESS,:display_name => "Pepe")],
                                              :subject => "This is a test" )

    puts appointment_message.to_soap.inspect

    appointment = Zimbra::Appointment.create(@credentials,appointment_message)

  end
=begin
  def test_task_creation

   @appointment = Zimbra::Task.create(@credentials,:subject => "Hola",
                                              :start_time => Zimbra::ZimbraTime.new(Time.parse("20090523")),
                                              :end_time => Zimbra::ZimbraTime.new(Time.parse("20090526")),
                                              :content => "THIS IS A TEST",
                                              :organizer => Zimbra::Organizer.new(:address => "admin@magec.es",:display_name => "juan"))
    assert_not_nil @appointment, "Error, Appointment cannot be created"

  end
=end
end
