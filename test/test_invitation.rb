$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'
require 'xml'

class TestInvitation < Test::Unit::TestCase

  def setup
    @message_id = "1"
    @subject = "THIS IS A TEST"
    @object = Zimbra::Message.new(:message_id => @message_id,:subject => @subject)
  end

  def test_from_xml
    xml =<<END
<inv type="appt"><tz dayoff="-420" stdoff="-480" id="(GMT-08.00) Pacific Time (US &amp; Canada)"><standard sec="0" hour="2" wkday="1" min="0" mon="11" week="1"/><daylight sec="0" hour="2" wkday="1" min="0" mon="3" week="2"/></tz><tz dayoff="120" stdoff="60" id="(GMT+01.00) Amsterdam / Berlin / Bern / Rome / Stockholm / Vienna"><standard sec="0" hour="3" wkday="1" min="0" mon="10" week="-1"/><daylight sec="0" hour="2" wkday="1" min="0" mon="3" week="-1"/></tz><comp d="1242469481000" class="PUB" loc="" transp="O" seq="0" uid="b7749e9c-34f5-4d1f-966c-848d8f6dbeaf" fb="T" status="CONF" fba="T" apptId="332" calItemId="332" url="" compNum="0" rsvp="1" x_uid="b7749e9c-34f5-4d1f-966c-848d8f6dbeaf" name="Hola"><at d="Admin A. Admin" a="admin@magec.es" rsvp="1" ptst="AC" role="REQ" url="admin@magec.es"/><alarm action="DISPLAY"><trigger><rel neg="1" m="5" related="START"/></trigger><desc/></alarm><fr>The following is a new meeting request: Subject: Hola Organizer: "Jose L. Fernandez" &lt;jose@magec.es> Time: Wednesday, May 6, 2009, 9:00:00 AM - ...</fr><desc>The following is a new meeting request:

Subject: Hola 
Organizer: "Jose L. Fernandez" &lt;jose@magec.es> 

Time: Wednesday, May 6, 2009, 9:00:00 AM - 9:30:00 AM GMT +01:00 Amsterdam / Berlin / Bern / Rome / Stockholm / Vienna
 
Invitees: "Admin A. Admin" &lt;admin@magec.es> 
"
*~*~*~*~*~*~*~*~*~*

</desc><or d="Jose L. Fernandez" a="jose@magec.es" url="jose@magec.es"/><s d="20090506T090000" tz="(GMT+01.00) Amsterdam / Berlin / Bern / Rome / Stockholm / Vienna"/><e d="20090506T093000" tz="(GMT+01.00) Amsterdam / Berlin / Bern / Rome / Stockholm / Vienna"/></comp></inv>
END
    doc = XML::Document.string(xml)
    invitation = Zimbra::Invitation.from_xml(doc.root)
    assert_not_nil invitation ,"Error, cannot create an invitation from xml"
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
