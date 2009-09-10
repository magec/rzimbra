module Zimbra

  class Account < Base
    
    def initialize
      @dirty_attributes = []
    end

    alias base_method_missing method_missing

    #
    # Creates an account
    # it accepts a Hash with the needed data
    # mandatory arguments are :name, :password and :attributes
    # ldap_attributes, in turn is a hash of attributes for the account :displayName is mandatory
    #
    def self.create(credentials,attributes)
      request = SOAP::SOAPElement.new("CreateAccountRequest")
      attributes[:ldap_attributes].each_pair do |key,value|
        current_element = SOAP::SOAPElement.new("a",value)
        current_element.extraattr[:n] = key.to_s
        request.add(current_element)
      end
      request.add SOAP::SOAPElement.new("name",attributes[:name])
      request.add SOAP::SOAPElement.new("password",attributes[:password])
      request.extraattr[:xmlns] = "urn:zimbraAdmin"
      result = driver.CreateAccountRequest(credentials,request)
      return result.first if result && result.first
    end

    def self.find_by_name(credentials,name)
      result = self.find_by(credentials,"name",name)
      return result.first if result && result.first
    end

    def self.find_by_id(credentials,id)
      result = self.find_by(credentials,"id",id)
      return result.first if result && result.first
    end

    def self.find_by(credentials,by,value)
      account = SOAP::SOAPElement.new("account",value)
      account.extraattr[:by]= by
      request = SOAP::SOAPElement.new("GetAccountRequest")
      request.extraattr[:xmlns] = "urn:zimbraAdmin"
      request.extraattr[:applyCos] = "0"
      request.add account
      result = driver.GetAccountRequest(credentials,request)
      result
    end
    
    def dirty_attributes_to_xml
      @dirty_attributes.map do |i| 
        j = SOAP::SOAPElement.new("a",i.value)
        j.extraattr[:n] = i.key
        j
      end
    end

    def save()
      request = SOAP::SOAPElement.new("ModifyAccountRequest")
      request.add SOAP::SOAPElement.new("id",self.account_id)
      request.extraattr[:xmlns] = "urn:zimbraAdmin"
      dirty_attributes_to_xml.each{ |i| request.add(i) }
      if @@driver.ModifyAccountRequest(@credentials,request)
        @dirty_attributes = []
      end
    end

    def delete
      @@driver.DeleteAccountRequest(@credentials,:id => self.account_id)
    end

    def method_missing(method_name,*args)
      begin
        raw_attribute = base_method_missing(method_name,*args) 
        return raw_attribute if raw_attribute
      rescue NoMethodError
      end
      normalized_method_name = method_name.to_s[-1,1] == "=" ? method_name.to_s[0..-2] : method_name.to_s
      if attribute = self.ldap_attributes.find{ |i| normalized_method_name == i.key }
        if method_name.to_s[-1,1] == "="
          attribute.value = *args
          if !@dirty_attributes.find{|i| normalized_method_name == i.key}
            @dirty_attributes << attribute
          end
        else
          attribute.value
        end
      end
    end

  end
end
