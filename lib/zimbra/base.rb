#!/usr/bin/ruby
require 'rubygems'
gem 'soap4r'
gem 'libxml-ruby'

require "soap/wsdlDriver"
require 'soap/header/simplehandler'
require 'soap/mapping'

require 'xml'

class Hash
  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end
  
  def stringify_keys
    inject({}) do |options, (key, value)|
      options
    end
  end
end


# Hack in order to set single headers to a soap call

class SOAP::Header::HandlerSet
  def reset
    @store = XSD::NamedElements.new
  end

  def set(header)
    reset
    add header
  end
end

class NoAttributeError < Exception;end
class ArrayExpectedError < Exception;end
class NoMetaInfFound < Exception;end

module Zimbra

  class Base;
    attr_accessor :value
  end

  class MailItem < Base; end

  class CalendarItem < MailItem; end

  module ZimbraObject
    module InstanceMethods

      def initialize(attrs = {})
        @meta_inf = META_INF.values.find { |i| "Zimbra::" + i[:class_name] == self.class.to_s }
        raises NoMetaInfFound unless @meta_inf
        @attributes ||= {}
        @saved = false
        self.attribut=(attrs)
      end


      def saved?
        return @saved
      end
      # Now we define an attributes method to work better with rails, this allow the use of multiparameter attributes
      def attribut=(new_attributes, guard_protected_attributes = true)

        return if new_attributes.nil?
        
        attributes = new_attributes.dup
        attributes.stringify_keys!

        multi_parameter_attributes = []
        #attributes = remove_attributes_protected_from_mass_assignment(attributes) if guard_protected_attributes
        
        attributes.each do |k, v|

          if k.include?("(")
            multi_parameter_attributes << [ k, v ]
          else
            # If we are setting the value of a container
            if @meta_inf[:containers].has_value?(k.to_s)
              raise ArrayExpectedError if v.class != Array
              aux = self.send(k.to_s)
              aux ||= []
              v.each {|item| aux << item }
              self.send(k.to_s+"=",aux)
            else
              self.send(k.to_s + "=", v)
            end
          end
        end
        assign_multiparameter_attributes(multi_parameter_attributes)
      end


      # Instantiates objects for all attribute classes that needs more than one constructor parameter. This is done
      # by calling new on the column type or aggregation type (through composed_of) object with these parameters.
      # So having the pairs written_on(1) = "2004", written_on(2) = "6", written_on(3) = "24", will instantiate
      # written_on (a date type) with Date.new("2004", "6", "24"). You can also specify a typecast character in the
      # parentheses to have the parameters typecasted before they're used in the constructor. Use i for Fixnum, f for Float,
      # s for String, and a for Array. If all the values for a given attribute are empty, the attribute will be set to nil.
      def assign_multiparameter_attributes(pairs)
        execute_callstack_for_multiparameter_attributes(
          extract_callstack_for_multiparameter_attributes(pairs)
        )
      end

      def column_for_attribute(name)
        return DateTime if name== "date"
      end

      def instantiate_time_object(name, values)
        if self.class.send(:create_time_zone_conversion_attribute?, name, column_for_attribute(name))
          Time.zone.local(*values)
        else
          Time.time_with_datetime_fallback(@@default_timezone, *values)
        end
      end

      def execute_callstack_for_multiparameter_attributes(callstack)
        errors = []
        callstack.each do |name, values|
          klass = Date if name == "date"
          if values.empty?
            send(name + "=", nil)
          else
            begin
              value = if Time == klass
                instantiate_time_object(name, values)
              elsif Date == klass
                begin
                  Date.new(*values)
                rescue ArgumentError => ex # if Date.new raises an exception on an invalid date
                  instantiate_time_object(name, values).to_date # we instantiate Time object and convert it back to a date thus using Time's logic in handling invalid dates
                end
              else
                klass.new(*values)
              end

              send(name + "=", value)
            rescue => ex
              errors << AttributeAssignmentError.new("error on assignment #{values.inspect} to #{name}", ex, name)
            end
          end
        end
        unless errors.empty?
          raise MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes"
        end
      end

      def extract_callstack_for_multiparameter_attributes(pairs)
        attributes = { }
        
        for pair in pairs
          multiparameter_name, value = pair
          attribute_name = multiparameter_name.split("(").first
          attributes[attribute_name] = [] unless attributes.include?(attribute_name)
          
          unless value.empty?
            attributes[attribute_name] <<
              [ find_parameter_position(multiparameter_name), type_cast_attribute_value(multiparameter_name, value) ]
          end
        end
        
        attributes.each { |name, values| attributes[name] = values.sort_by{ |v| v.first }.collect { |v| v.last } }
      end
      
      def type_cast_attribute_value(multiparameter_name, value)
        multiparameter_name =~ /\([0-9]*([a-z])\)/ ? value.send("to_" + $1) : value
      end
      
      def find_parameter_position(multiparameter_name)
        multiparameter_name.scan(/\(([0-9]*).*\)/).first.first
      end
      
      # Returns a comma-separated pair list, like "key1 = val1, key2 = val2".
      def comma_pair_list(hash)
        hash.inject([]) { |list, pair| list << "#{pair.first} = #{pair.last}" }.join(", ")
      end

      


      def to_soap

        attribute_to_soap = {}

        current_element = SOAP::SOAPElement.new(@meta_inf[:element_name],value)
        # First we fill in the attributes
        @meta_inf[:attributes].each { |key,value| ( aux = self.send(value) ) && current_element.extraattr[key] = aux}
        # Then the elements
        @meta_inf[:elements].each   do |key,value|
          aux = self.send(value)
          if aux.respond_to?("to_soap")
            current_element.add(aux.to_soap)
          else
            current_element.add(SOAP::SOAPElement.new(key.to_s,aux) )
          end
        end
        # The the containers
        @meta_inf[:containers].each { |key,value| ( aux = self.send(value) ) && aux.each { |aux_value| current_element.add( aux_value.to_soap )  } }

        current_element
      end

      def method_missing(method_name,*args)
        if @attributes.has_key?(method_name)
          return @attributes[method_name]
        end

        # Assignment
        if method_name.to_s[-1] == 61 && @attributes.has_key?(method_name.to_s[0..-2])
          return @attributes[method_name.to_s[0..-2].to_sym] = args[0]
        end

        # If the attribute is not set
        if @meta_inf[:attributes].has_value?(method_name.to_s)
          return nil
        end

        # Initialization

        if method_name.to_s[-1] == 61 && self.class::ATTR_MAPPING.has_value?(method_name.to_s[0..-2])
          return @attributes[method_name.to_s[0..-2].to_sym] = args[0]
        end

        raise NoMethodError.new(method_name.to_s)
      end

    end

    module ClassMethods
      def from_xml(xml)
        object = self.new
        xml.attributes.each do |attribute|
#          object.send(self::ATTR_MAPPING[attribute.name.to_sym] + "=",attribute.value)
#          puts attribute.to_s
          attributes = object.send("attributes")
          raise "Attribute: " + attribute.name + " does not have any mapping" unless self::ATTR_MAPPING[attribute.name.to_sym]
          attributes ||= {}
          attributes[self::ATTR_MAPPING[attribute.name.to_sym].to_sym] = attribute.value
          object.send("attributes=",attributes)
        end
        xml.children.each do |child|
          object.value = child.to_s if child.text?
          if method_name = self::CONTAINER_MAPPING[child.name.to_sym]
            container = object.send(method_name) || []
            container << eval(META_INF[child.name.to_sym][:class_name]).from_xml(child)
            object.send(method_name + "=",container)
          end
          if method_name = self::ELEMENT_MAPPING[child.name.to_sym]
            object.send(method_name + "=",child.children.first.to_s)
          end
        end
        object
      end
    end
  end

  # The creation of the base classes is made automagically
  # class_name maps the element name of the xml to the ruby class that is to be created
  # element_name is the xml name of the element
  # attributes is a list mapping the element attributes with method names in ruby, the key is the xml and the value the mehod
  # containers is used when another objects are inside this one.

  META_INF = {
    :comp => {
      :parent => Base,
      :class_name => "InvitationComponent",
      :element_name => "comp",
      :attributes => {:status => "status",:fb => "f",:fba => "fba",:transp => "transp",:class  => "type ",
        :allDay => "all_day",:name => "name",:loc => "location",:isOrg => "is_org",:t => "t",
        :seq  => "seq ",:priority => "priority",:percentComplete => "percent_complete",:completed => "completed",:url => "url"},
      :elements => {:s => "start_time",:dur => "duration",:or => "organizer"},:containers => {:at => "atendees"}
    },
    :appt => {
      :parent => CalendarItem,
      :class_name => "Appointment",
      :element_name => "appt",
      :attributes => {:alarm => "alarm", :loc => "loc", :transp => "transparency", :fb => "fb", :id => "calendar_item_id", :rev => "rev", :fba => "fba", :isOrg => ":is_org",:t => "t",
        :allDay => "all_day", :score => "score", :compNum => "compNum", :name => "name", :s => "s", :d => "date", :ms => "ms", :md => "md", :class => "class_name", :uid => "uid", :otherAtt => "other_attendees",
        :ptst => "ptst", :cm => "cm", :status => "status", :l => "l", :dur => "duration", :sf => "sf", :f => "f", :x_uid => "x_uid", :invId => "invitation_id"},
      :elements => {:or => "organizer",:fr => "default_fragment" },
      :containers => {:inst => "instances"}
    },
    :task => {
      :parent => CalendarItem,
      :class_name => "Task",
      :element_name => "task",
      :attributes => {:alarm => "alarm", :loc => "loc", :transp => "transparency", :fb => "fb", :id => "calendar_item_id", :rev => "rev", :fba => "fba", :isOrg => ":is_org",:t => "t",
        :allDay => "all_day", :score => "score", :compNum => "compNum", :name => "name", :s => "s", :d => "date", :ms => "ms", :md => "md", :class => "class_name", :uid => "uid", :otherAtt => "other_attendees",
        :ptst => "ptst", :cm => "cm", :status => "status", :l => "l", :dur => "duration", :sf => "sf", :f => "f", :x_uid => "x_uid", :invId => "invitation_id"},
      :elements => {:or => "organizer",:fr => "default_fragment" },
      :containers => {:inst => "instances"}
    },
    :dl => {
      :parent => Base,
      :class_name => "DistributionList",
      :element_name => "dl",
      :attributes => {:name => "name",:id => "dl_id"},
      :elements => {},
      :containers => {:dlm => "members",:a => "dl_attributes"},
    },
    :dlm => {
      :parent => Base,
      :class_name => "DistributionListMember",
      :element_name => "dlm",
      :attributes => {},
      :elements => {},
      :containers => {}
    },
    :inst => {
      :parent => Base,
      :class_name => "CalendarInstanceData",
      :element_name => "inst",
      :attributes => {:s => "start_time_secs", :tzo => "timezone", :ex => "ex",:ridZ => "ridZ", :f => "fragment" , :dur => "duration", :isOrg => "isOrg", :otherAtt => "otherAtt"},
      :elements => {},
      :containers => {:inst => "instance_data" }
    },
    :folder => {
      :parent => MailItem,
      :class_name => "Folder",
      :element_name => "folder",
      :attributes => {:id => "folder_id", :name => "folder_name", :l => "parent_id", :f => "flags", :color => "color",
        :u => "unread", :n => "msg_count", :s => "total_size", :view => "default_type",
        :url=> "remote_url", :perm => "effective_perms", :rest => "rest_url",:path => "path",:rev => "rev"
      },
      :elements => {},
      :containers => {:folder => "folders"}
    },
    :c => {
      :parent => MailItem,
      :class_name => "Conversation",
      :element_name => "c",
      :attributes => {:id=> "conv_id",:t=> "tags",:n=> "num_msgs",:total=> "all_msgs",:score => "score",:d=> "date",:f=> "flags",:sf=>"sort_field"},
      :elements => {:su => "subject",:fr => "fragment"},
      :containers => {:e => "addresses",:m => "mails"}
    },
    :e => {
      :parent => Base,
      :class_name => "Address",
      :element_name => "e",
      :attributes => {:a => "address",:d => "display_name",:t => "type_address",:p => "personal_name"},
      :elements => {},:containers => {}
    },
    :m => {
      :parent => MailItem,
      :class_name => "Message",
      :element_name => "m",
      :attributes => {:id => "message_id",:d => "date",:sf => "sort_field",:score => "score",:t => "t", :sd => "sd", :f => "f",:cm => "cm",:l => "parent_id",:cid => "cid",:s =>"s",:rev => "rev",:idnt => "idnt"},
      :elements => {:su => "subject",:fr => "fragment",:inv => "invitation"},:containers => {:e => "addresses",:mp => "parts"}
    },
    :a => {
      :parent => Base,
      :class_name => "AccountAttribute",
      :element_name => "a",
      :attributes => {:n => "key"},
      :elements => {},:containers => {}
    },
    :account => {
      :parent => Base,
      :class_name => "Account",
      :element_name => "account",
      :attributes => {:name => "name" ,:id => "account_id"},
      :elements => {},:containers => {:a => "ldap_attributes"}
    },
    :mp => {
       :parent => Base,
       :class_name => "MimePart",
       :element_name => "mp",
       :attributes => {:part => "part",:body => "body",:s => "size",:mid => "message_id",:cid => "conv_id",:truncated => "truncated",:ct => "content_type",:name => "name",:cd => "content_disposition",:filename => "filename",:ci => "content_id",:cl => "content_location"},
       :elements => {:content => "content"}, :containers => { :mp => "parts"}

    },
    :inv => {
      :parent => Base,
      :class_name => "Invitation",
      :element_name => "inv",
      :attributes => {:uid => "uid" },
      :elements => {},:containers => {:comp => "components"}
    },
    :s => {
      :parent => Base,
      :class_name => "ZimbraTime",
      :element_name => "s",
      :attributes => {:d => "date",:tz => "timezone_identifier" },
      :elements => {},:containers => {}
    },
    :dur => {
      :parent => Base,
      :class_name => "Duration",
      :element_name => "dur",
      :attributes => {:neg => "neg",:w => "weeks",:d => "days",:h => "hours",:m => "mins",:s => "secs"},
      :elements => {},:containers => {}
    },
    :or => {
      :parent => Base,
      :class_name => "Organizer",
      :element_name => "or",
      :attributes => { :a => "address",:d => "display_name",:sentBy => "sent_by",:dir => "dir",:lang => "language"},
      :elements => {},:containers => {}
    },
    :at => {
      :parent => Base,
      :class_name => "Atendee",
      :element_name => "at",
      :attributes => { :a => "address",:d => "display_name",:sentBy => "sent_by",:dir => "dir",:lang => "language",:role => "role",:ptst => "participation_status",
        :rsvp => "rsvp",:cutype => "cutype",:member => "member",:delTo => "delegated_to",:delFrom => "delegated_from"},
      :elements => {},:containers => {}
    }

  }

  META_INF.each_value do |current_class_info|
    current_class = Class.new(current_class_info[:parent])

    # First we define every method that the class will have

    current_class_info[:containers].merge(current_class_info[:elements]).each_pair do |key,value|
      current_class.instance_eval("attr_accessor :#{value}")
    end

    # Now we set the class methods plus a couple of Constants needed by that class methods

    current_class.extend(ZimbraObject::ClassMethods)
    current_class.const_set("CONTAINER_MAPPING",current_class_info[:containers])
    current_class.const_set("ELEMENT_MAPPING",current_class_info[:elements])
    current_class.const_set("ATTR_MAPPING",current_class_info[:attributes])
    const_set(current_class_info[:class_name],current_class)
    puts "Defined class: " + current_class_info[:class_name] if $DEBUG
  end

  # This class will handle the header in order to authenticate

  class ClientAuthHeaderHandler < SOAP::Header::SimpleHandler
    MyHeaderName = XSD::QName.new("urn:zimbra", "context")
    def initialize(credentials)
      super(MyHeaderName)
      @credentials = credentials
    end

    def on_simple_outbound
      { "sessionId" => @credentials[:sessionId],"authToken" => @credentials[:authToken] }
    end

  end


  # Instead of inherit from the driver i make use of objetco composition, so the actual calls are delegated
  # to a SOAPClient instance that deals with all of the SOAP stuff
  # As soon is I get how to map arbitrary objects into SOAP calls by means of the mapping registry and stuff
  # (black magic not documented in soap4r) I'll rewrite this metaprogramming hell, but by now it does the job.

  class SOAPClient
    WSDL_URL = "file://#{File.expand_path(File.dirname(__FILE__))}/zimbra.wsdl"

    @@lock = Mutex.new

    def initialize(endpoint_url = "")
      factory = SOAP::WSDLDriverFactory.new(WSDL_URL)
      @driver = factory.create_rpc_driver
      @driver.endpoint_url = endpoint_url
      @driver.options['protocol.http.ssl_config.options'] = OpenSSL::SSL::OP_CIPHER_SERVER_PREFERENCE
      @driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE
      @driver.return_response_as_xml = true
      @driver.wiredump_dev = STDOUT if $DEBUG
    end

    def login(user,password)
      response = @driver.AuthRequest(:name => user,:password => password)
      xml_response = XML::Document.string(response)
      credentials = {}
      result =  xml_response.find("/soap:Envelope/soap:Body/*/*").map do |element|
        credentials[element.name.to_sym] = element.child.to_s
      end
      return credentials
    end

    # This is where the magic happends, I make an object mapping myself
    # I receive the message I check what class is it and call the class method (from_xml) of it.
    # This is what soap4r should do for me but I dont get it to do so ad have no more time to spend on it.
    # We expect every call to have the credentials as the first argument

    def method_missing(method_name,*args)
      if @driver.respond_to?(method_name.to_s)
        @@lock.synchronize do
          credentials = args.shift
          @driver.headerhandler.set(ClientAuthHeaderHandler.new(credentials))
          xml_response = XML::Document.string(@driver.send(method_name.to_s,*args))
          result_array = xml_response.find("/soap:Envelope/soap:Body/*/*")
          result =  result_array.map do |element|
            current_object = eval(META_INF[element.name.to_sym][:class_name]).from_xml(element)
            current_object.credentials = credentials
            current_object
          end
          
          if result.length == 0
            return xml_response.find("/soap:Envelope/soap:Body/*")[0]
          else
            return result
          end
        end
        #TODO: The session has to be refreshed sometimes
      else
        puts "ERROR #{method_name.to_s}"
        raise NoMethodError
      end
    end

  end


  class Base

    attr_accessor :value
    attr_accessor :credentials
    attr_accessor :attributes

    include ZimbraObject::InstanceMethods

    @@config = {}

    def self.config(configuration)
      @@config = configuration
    end

    def self.get_credentials(user,password)
      return driver.login(user,password)
    end

    def self.driver
      @@driver ||= SOAPClient.new(@@config[:endpoint_url])
    end

  end

end

