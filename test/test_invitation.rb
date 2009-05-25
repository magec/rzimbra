$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestInvitation < Test::Unit::TestCase

  def setup
    @message_id = "1"
    @subject = "THIS IS A TEST"
    @object = Zimbra::Message.new(:message_id => @message_id,:subject => @subject)
  end


  def test_invitation
    @address = "test@test.es"
    @at_address = "test2@test.es"
    @display_name = "Foo, Bar."


    component = Zimbra::InvitationComponent.new(:status => "TENT",:fba => "F",:percent_complete => "0",
                                                :start_time => Time.now,:duration => "10m",
                                                :organizer => Zimbra::Organizer.new(:address => @address,:display_name => "TEST"),
                                                :atendees => [Zimbra::Atendee.new(:address => @at_adress,:display_name => "TEST2",
                                                                                  :role => "REQ",:participation_status => "TE")])


    assert_not_nil invitation = Zimbra::Invitation.new(:components => [component]),"Error, creating the invitation"

  end
end
