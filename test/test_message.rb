$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestMessage < Test::Unit::TestCase

  def setup
    Zimbra::Base.config(:endpoint_url => APP_CONFIG["end_point_url"])
    @credentials = Zimbra::Folder.get_credentials(APP_CONFIG["admin_login"],APP_CONFIG["admin_password"])
  end

  def test_inviation_message
    xml=<<END
<m d="1242472492000" sf="1242472492000" score="1.0" sd="1242469481000" f="rv" cm="1" l="3" cid="337" id="331" s="4909" rev="7697"><e d="Jose" a="jose@magec.es" t="f" p="Jose L. Fernandez"/><e d="Admin" a="admin@magec.es" t="t" p="Admin A. Admin"/><su>Hola</su><fr>The following is a new meeting request: Subject: Hola Organizer: "Jose L. Fernandez" &lt;jose@magec.es> Time: Wednesday, May 6, 2009, 9:00:00 AM - ...</fr><mid>&lt;10412273.131242469481770.JavaMail.root@hiro.magec.es></mid><inv type="appt"><tz dayoff="-420" stdoff="-480" id="(GMT-08.00) Pacific Time (US &amp; Canada)"><standard sec="0" hour="2" wkday="1" min="0" mon="11" week="1"/><daylight sec="0" hour="2" wkday="1" min="0" mon="3" week="2"/></tz><tz dayoff="120" stdoff="60" id="(GMT+01.00) Amsterdam / Berlin / Bern / Rome / Stockholm / Vienna"><standard sec="0" hour="3" wkday="1" min="0" mon="10" week="-1"/><daylight sec="0" hour="2" wkday="1" min="0" mon="3" week="-1"/></tz><comp d="1242469481000" class="PUB" loc="" transp="O" seq="0" uid="b7749e9c-34f5-4d1f-966c-848d8f6dbeaf" fb="T" status="CONF" fba="T" apptId="332" calItemId="332" url="" compNum="0" rsvp="1" x_uid="b7749e9c-34f5-4d1f-966c-848d8f6dbeaf" name="Hola"><at d="Admin A. Admin" a="admin@magec.es" rsvp="1" ptst="AC" role="REQ" url="admin@magec.es"/><alarm action="DISPLAY"><trigger><rel neg="1" m="5" related="START"/></trigger><desc/></alarm><fr>The following is a new meeting request: Subject: Hola Organizer: "Jose L. Fernandez" &lt;jose@magec.es> Time: Wednesday, May 6, 2009, 9:00:00 AM - ...</fr><desc>The following is a new meeting request:

Subject: Hola 
Organizer: "Jose L. Fernandez" &lt;jose@magec.es> 

Time: Wednesday, May 6, 2009, 9:00:00 AM - 9:30:00 AM GMT +01:00 Amsterdam / Berlin / Bern / Rome / Stockholm / Vienna
 
Invitees: "Admin A. Admin" &lt;admin@magec.es> 

*~*~*~*~*~*~*~*~*~*

</desc><or d="Jose L. Fernandez" a="jose@magec.es" url="jose@magec.es"/><s d="20090506T090000" tz="(GMT+01.00) Amsterdam / Berlin / Bern / Rome / Stockholm / Vienna"/><e d="20090506T093000" tz="(GMT+01.00) Amsterdam / Berlin / Bern / Rome / Stockholm / Vienna"/></comp></inv><mp part="TEXT" s="3243" ct="multipart/alternative"><mp part="1" body="1" s="304" ct="text/plain"><content>The following is a new meeting request:

Subject: Hola 
Organizer: "Jose L. Fernandez" &lt;jose@magec.es> 

Time: Wednesday, May 6, 2009, 9:00:00 AM - 9:30:00 AM GMT +01:00 Amsterdam / Berlin / Bern / Rome / Stockholm / Vienna
 
Invitees: "Admin A. Admin" &lt;admin@magec.es> 

*~*~*~*~*~*~*~*~*~*

</content></mp><mp part="2" s="601" ct="text/html"/><mp part="3" filename="meeting.ics" s="1914" ct="text/calendar"/></mp></m>
END
    doc = XML::Document.string(xml)
    message = Zimbra::Message.from_xml(doc.root)
    assert_not_nil message.invitation,"Error, cannot get a nested invitation an invitation from xml"
    assert_kind_of Zimbra::Invitation , message.invitation, "Error, cannot get a nested invitation an invitation from xml"
  end
  
  
  def test_find_by_query
    result =  Zimbra::Message.find_by_query(@credentials,"in:sent")
    assert_not_nil result,"Error"
    result =  Zimbra::Conversation.find_by_query(@credentials,"in:sent")
    assert_not_nil result,"Error"
  end

end
