$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestSoap < Test::Unit::TestCase

  def setup
    @client = Zimbra::Base.config(:endpoint_url => APP_CONFIG["end_point_url"])
    @client = Zimbra::Base.driver
    @credentials = Zimbra::Base.get_credentials(APP_CONFIG["admin_login"],APP_CONFIG["admin_password"])
    assert(@credentials,"Login was incorrect")
  end
  
  def stest_thread_safety
    threads = []
    test_times = 100
    account = SOAP::SOAPElement.new("account",APP_CONFIG["admin_login"]);
    account.extraattr[:by]= "name"
    bad_credentials = @credentials.clone
    bad_credentials[:authToken] = ""
    credentials_array = []
    test_times.times do |i|
      if i % 2 == 0 
        credentials = bad_credentials
      else
        credentials = @credentials
      end
      threads << Thread.new(i,credentials,account) do 
        begin
          @client.GetAccountRequest(credentials,:account => account)
        rescue
          raise "ERROR : #{i} No thread safety :#{$!}" if i % 2 != 0
        end
      end
    end
    threads.each{|i| i.join }
  end

  def test_get_folder
    assert(@client.GetFolderRequest(@credentials,:folder => {:xmlattr_path => "/"}) ,"There are no folders")
  end

  def test_get_messages
    assert(@client.SearchRequest(@credentials,:query => "in:inbox").length != 0)
    assert_raise(SOAP::FaultError) { @client.SearchRequest(@credentials,:query => "")}
    assert (@client.SearchRequest(@credentials,:query => "in").length == 0),"This query should return 0 results"
  end

  def test_login
    assert(true)
  end

end
