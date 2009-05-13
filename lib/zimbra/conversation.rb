module Zimbra
  class Conversation < MailItem
    self.type = "conversation"

    def self.find_by_id(credentials,args)
      result = {}
      args.each{|key,value| result[("xmlattr_"+key.to_s).to_sym] = value }
      result[:xmlattr_cid] = args[:cid]
      return driver.SearchConvRequest(credentials,result.merge({:xmlattr_fetch => "1",:xmlattr_html => "1"}))
    end

  end
end
