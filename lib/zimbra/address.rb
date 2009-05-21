module Zimbra
  # An abstraction of an email address as used by zimbra
  class Address < Base
    # (f)rom, (t)o, (c)c, (b)cc, (r)eply-to, (s)ender
    #attr_accessor :type
    # The commeny/name part of an address
    #attr_accessor :personal_name
    # If we have personal, first word in "word1 word2" format, or last word in "word1, word2" format.
    # if no personal, take string before "@" in email-address.
    #attr_accessor :display_name
    # The actual address as given by the user, the one that is going to be used when sending
    #attr_accessor :value

  end
end
