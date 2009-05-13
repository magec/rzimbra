module Zimbra
  class Folder < MailItem
    self.type = "folder"

    def self.find_by_path(credentials,path)
      result = driver.GetFolderRequest(credentials,:folder => {:xmlattr_path => path})
      return result.first if result && result.first
    end

    def self.find_by_id(credentials,folder_id)
      result = driver.GetFolderRequest(credentials,:folder => {:xmlattr_l => folder_id})
      return result.first if result && result.first
    end
  end
end
