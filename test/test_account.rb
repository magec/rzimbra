$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestAccount < Test::Unit::TestCase
  
  TEST_PASSWORD = APP_CONFIG["test_password"]
  TEST_NAME     = APP_CONFIG["test_login"]
puts APP_CONFIG["end_point_url"]
  def setup
    Zimbra::Base.config(:endpoint_url => APP_CONFIG["end_point_url"])
    @credentials = Zimbra::Folder.get_credentials(APP_CONFIG["admin_login"],APP_CONFIG["admin_password"])
    if !@account = Zimbra::Account.find_by_name(@credentials,TEST_NAME)
      @account = Zimbra::Account.create(@credentials,:name => TEST_NAME,:password => TEST_PASSWORD, :ldap_attributes => {:displayName => TEST_NAME})
    end
    assert_not_nil @account, "An account cant be retreived or created"
  end

  def test_find
    account = Zimbra::Account.find_by_name(@credentials,TEST_NAME)
    assert_not_nil account,"Cant find the given account"
    account2 = Zimbra::Account.find_by_id(@credentials,account.account_id) 
    assert_not_nil account2, "Cant find by id a previously created and retreived account account" 
    assert_equal account.name,account2.name, "An id lookup of a given account does not correspond with itself"
  end

  def test_attirbutes
    assert_equal @account.displayName, TEST_NAME, "attrributes differ"
    @account.displayName = "NEWONE"
    assert_equal @account.displayName, "NEWONE", "cannot set attribute"
  end


  def test_save
    @account.displayName = "PEPITO"
    assert @account.save, "Cannot be saved"
    assert_equal Zimbra::Account.find_by_name(@credentials,TEST_NAME).displayName, "PEPITO", "Changed attribute has not been saved"
  end

  def teardown
    assert @account.delete,"Can not delete the account"
  end


end
