module Zimbra
  class MailItem < Zimbra::Base
    
    class << self 
      attr_accessor :type
    end

    def unread?
      return self.flags =~ /u/
    end

    #
    # This method queries the server for the given objects 
    # it accepts a search_options hash to change the search behavior 
    #       :limit      Is an integer specifying the maximum number of results to return. if limt <= 0 or limit > 1000 then it defaults to 30.
    #       :offset     Is an integer specifying the 0-based offset into the results list to return as the first result for this search operation.  
    #       :fetch      "1"  is specified, the first hit will be expanded inline (messages only at present)
    #                   "{item-id}", only the message with the given {item-id} is expanded inline
    #                   "all", all hits are expanded inline
    #       :html="1"   Is also specified, inlined hits will return HTML parts if available
    #       :read="1"   Is also specified, inlined hits will be marked as read
    #       :neuter="0" is also specified, images in inlined HTML parts will not be "neutered"
    #       if <header>s are requested, any matching headers are included in inlined message hits
    #         + if max="{max-inlined-length}" is specified, inlined body content in limited to the given length;
    #          if the part is truncated, truncated="1" is specified on the <mp> in question
    
    # if recip="1" is specified
    #     + returned sent messages will contain the set of "To:" recipients instead of the sender
    #     + returned conversations whose first hit was sent by the user will contain
    #       that hit's "To:" recipients instead of the conversation's sender list
    
    #   {group-by} = DEPRECATED.  Use TYPES instead. 
    #     {types}      = comma-separated list.  Legal values are:
    #                conversation|message|contact|appointment|task|note|wiki|document
    #                (default is "conversation")
    
    #         **NOTE: only ONE of message, conversation may be set. If
    #                 both are set, the first is used.
    
    #     {sort-by}  = default is "dateDesc"
    #                Valid choices:
    #                     dateDesc|dateAsc|subjDesc|subjAsc|nameDesc|nameAsc|none(*)
    #                     * - If sort-by is "none" then cursors MUST NOT be
    #                         used, and some searches are impossible
    #                         (searches that require intersection of complex
    #                         sub-ops).  Server will throw an
    #                         IllegalArgumentException if the search is
    #                         invalid.
    
    #                ADDITIONAL SORT MODES FOR TASKS: valid only if types="task" (and task alone):
    #                         taskDueAsc|taskDueDesc|taskStatusAsc|taskStatusDesc|taskPercCompletedAsc|taskPercCompletedDesc
    
    #   {more-flag} = 1 if there are more search results remaining. 

   
    def self.find_all_by_query(credentials,query,search_options = {})
      result = {}
      search_options.each{|key,value| result[("xmlattr_"+key.to_s).to_sym] = value }
      result[:query] = query
      return driver.SearchRequest(credentials,result.merge({:xmlattr_fetch => "all",:xmlattr_types => self.type}))
    end

    def self.find_by_query(credentials,query,search_options = {})
      result = self.find_all_by_query(credentials,query,search_options)
      return result[0] if result && result.length > 0
    end

    def self.method_missing(method_name, *args)
      if method_name.to_s =~ /^find_by_(\w+)/
        credentials = args.shift
        puts $1+":"+args[0]
        return self.find_by_query(credentials,$1+":"+args[0])
      end
      if method_name.to_s =~ /^find_all_by_(\w+)/
        credentials = args.shift
        puts $1+":"+args[0]
        return self.find_all_by_query(credentials,$1+":"+args[0])
      end
    end
  end
end
