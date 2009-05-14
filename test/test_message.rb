$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestMessage < Test::Unit::TestCase

  def setup
    Zimbra::Base.config(:endpoint_url => APP_CONFIG["end_point_url"])
    @credentials = Zimbra::Folder.get_credentials(APP_CONFIG["admin_login"],APP_CONFIG["admin_password"])
  end

  def test_find_by_query
    result =  Zimbra::Message.find_by_query(@credentials,"in:sent")
    assert_not_nil result,"Error"
    result =  Zimbra::Conversation.find_by_query(@credentials,"in:sent")
    assert_not_nil result,"Error"
  end
end
