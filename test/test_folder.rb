$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestFolder < Test::Unit::TestCase
  
  def setup
    Zimbra::Base.config(:endpoint_url => APP_CONFIG["end_point_url"])
    @credentials = Zimbra::Folder.get_credentials(APP_CONFIG["admin_login"],APP_CONFIG["admin_password"])
  end

  
  def test_find_folders_by_path
    assert_not_nil Zimbra::Folder.find_by_path(@credentials,"/"), "The number of folders can't be 0"
  end

  def test_find_folders_by_id
    folder = Zimbra::Folder.find_by_path(@credentials,"/")
    returned_id = Zimbra::Folder.find_by_id(@credentials,folder.folder_id).folder_id.to_s
    assert_equal returned_id,folder.folder_id, "The id we asked for (#{folder.folder_id}) differs from the one returned (#{returned_id})"
  end

  def test_login
    assert(true)
  end

  def test_nil_atribute
    folder = Zimbra::Folder.find_by_path(@credentials,"/")
    folder.folders.each{|i| i.default_type }
  end

end
