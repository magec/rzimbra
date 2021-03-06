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
        i.personal_name ? i.personal_name + " " + "<" + i.address + ">" : i.address if i.type_address == "f"
      end.compact.join ","
      result
    end
    
    def isFlagged
      puts "WARNING:UNINPLEMENTED isFlagged"
      return false
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
    

    def self.find_by_id(credentials,id)
      request = SOAP::SOAPElement.new("GetMsgRequest")
      m = SOAP::SOAPElement.new("m")
      m.extraattr[:id] = id
      request.extraattr["xmlns"] = "urn:zimbraMail"
      request.add(m)
      result = @@driver.GetMsgRequest(credentials,request)
      return result[0] if result
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

    # some helpers methods to easy the pain of setting fields

    def display_addresses_by_type(type)
      aux = self.addresses.select {|i| i.type_address == type}
      return ( aux ? aux.map{|i| i.address if i }.join(",") : nil )
    end

    def set_addresses(address_type,address_string)
      current_addresses = self.addresses.select {|i| i.type_address == address_type}
      self.addresses = self.addresses - current_addresses
      address_string.split(",").each{|i| self.addresses <<  Zimbra::Address.new(:address => i, :type_address => address_type ) }
    end

    def from 
      display_addresses_by_type "f"
    end

    def from=(from)
      set_addresses("f",from)
    end
  
    def to
      display_addresses_by_type "t"
    end

    def to=(to)
      set_addresses("t",to)
    end

    def cc
      display_addresses_by_type "cc"
    end
    
    def cc=(cc)
      set_addresses("cc",cc) if cc
    end
    
    def body_object
      body_object = nil
      self.parts.find do |i|
        if i.body== "1"
          body_object = i
          break
        else
          i.parts.find do |j|
            if j.body=="1"
              body_object = j
              break
            end
          end
        end
      end
      body_object
    end
    
    def body
      return body_object.content if body_object
    end

    def body=(body)
      if body_object
        body_object.content = body
        return true
      else
        mp = MimePart.new(:part => "TEXT",:content_type => "text/plain",:body => "1")
        mp.content = body
        self.parts << mp
      end
    end

    def send_invitation_response(verb)
      # ACCEPT, COMPLETED, DECLINE, DELEGATED, TENTATIVE
      first_component = invitation.components.first
      return @@driver.SendInviteReplyRequest(@credentials,:xmlattr_verb => verb,:xmlattr_compNum => first_component.comp_num,:xmlattr_id => message_id)
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
