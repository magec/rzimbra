module Zimbra

  class Message < MailItem

    self.type = "message"

    def empty_from?
      return self.addresses.find { |i| i.attributes[:type] == "f" } == []
    end

    def folder
      Folder.find_by_id(@credentials,parent_id)
    end

    def from_hr
      current = ""
      result = self.addresses.map do |i|
        i.personal_name ? i.personal_name + " " + "<" + i.address + ">" : i.address if i.attributes[:type] == "f"
      end.compact.join ","
      result
    end

    def isFlagged
      puts "WARNING:UNINPLEMENTED isFlagged"
      return false
    end

    def date_rb
      return Time.at(@attributes["date"].to_f/1000)
    end

    def body
      parts[0].parts.find { |i| i.body == "1" }.content if parts && parts[0] && parts[0].parts
    end

    def simple_mail(from,to,subject,message)
      self.subject = subject
      self.addresses << Zimbra::Address.new(:address => from, :type_address => "f")
      self.addresses << Zimbra::Address.new(:address => to, :type_address => "t")
      mp = MimePart.new(:part => "TEXT",:content_type => "text/plain")
      mp.content = message
      self.parts << mp
    end
    

    def delete
      request_method = "MsgActionRequest"
      request = SOAP::SOAPElement.new(request_method)      
      request.extraattr["xmlns"] = "urn:zimbraMail"
      request.add(Zimbra::Action.new(:op => "delete",:action_id => self.message_id).to_soap)
      @@driver.MsgActionRequest(@credentials,request)
      
    end
    
    def send_message(attrs = {})
      request = prepare_request("SendMsgRequest")
      request.extraattr["noSave"] = ( !attrs[:save] ? "1" : "0" ) if attrs[:save]
      result = @@driver.SendMsgRequest(@credentials,request)
      return self.message_id = result.first.message_id 
    end

    def self.create(credentials,attributes)
      message = Message.new(attributes)
      message.credentials = credentials
      message.send_message
    end


    private
    
    def prepare_request(request_name)
      request = SOAP::SOAPElement.new(request_name)      
      request.extraattr["xmlns"] = "urn:zimbraMail"
      request.add(to_soap)
      return request
    end

  end
end
