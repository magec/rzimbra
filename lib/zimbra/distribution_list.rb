module Zimbra
  class DistributionList < Base
    def self.find_by_name(credentials,name)
      request = SOAP::SOAPElement.new("GetDistributionListRequest")
      distribution_list = SOAP::SOAPElement.new("dl",name)
      distribution_list.extraattr["by"] = "name"

      request.add distribution_list
      request.extraattr[:xmlns] = "urn:zimbraAdmin"
      driver.GetDistributionListRequest(credentials,request)
    end

    
  end
end
