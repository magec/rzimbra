$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestDistributionList < Test::Unit::TestCase
  
  TEST_PASSWORD = APP_CONFIG["test_password"]
  TEST_NAME     = APP_CONFIG["test_login"]
  DIST_NAME  = APP_CONFIG["distribution_list"]

  def setup
    Zimbra::Base.config(:endpoint_url => APP_CONFIG["end_point_url"])
    @credentials = Zimbra::Base.get_credentials(APP_CONFIG["admin_login"],APP_CONFIG["admin_password"])
  end

  def test_find
    assert_not_nil Zimbra::DistributionList.find_by_name(@credentials,DIST_NAME), "Error se esperaba una lista"
  end

  def test_find_with_members
    assert_not_nil Zimbra::DistributionList.find_by_name(@credentials,DIST_NAME)[0].members, "Error se esperaba una lista"
  end

end
