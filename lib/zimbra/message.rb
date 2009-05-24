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

  end
end
