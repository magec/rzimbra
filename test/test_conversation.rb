$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestConversation < Test::Unit::TestCase

  def setup
    Zimbra::Base.config(:endpoint_url => APP_CONFIG["end_point_url"])
    @credentials = Zimbra::Folder.get_credentials(APP_CONFIG["admin_login"],APP_CONFIG["admin_password"])
  end

  def test_find_by_query
    result = Zimbra::Conversation.find_by_query(@credentials,"in:inbox")
    assert_not_nil result,"Error"
    result2 = Zimbra::Conversation.find_all_by_query(@credentials,"in:inbox")
    assert_equal result2[0].conv_id, result.conv_id
    result = Zimbra::Conversation.find_by_from(@credentials,"admin")
    assert_not_nil result,"Error"
  end

  def test_find_by_query_with_options
    result = Zimbra::Conversation.find_all_by_query(@credentials,"in:inbox",:limit => "2",:html => "1")
    assert_equal result.length, 2
  end
end
