$:.unshift(File.dirname(__FILE__) + '/../lib').unshift(File.dirname(__FILE__))

require 'test/unit'
require 'rzimbra'
require 'config/load_config'

class TestMessage < Test::Unit::TestCase

  def setup
    @message_id = "1"
    @subject = "THIS IS A TEST"
    @object = Zimbra::Message.new(:message_id => @message_id,:subject => @subject)
  end

  def test_wrong_attributes
    assert_raises NoMethodError  do
      Zimbra::Appointment.new(:foo => "bar")
    end
  end

  def test_attribute_initialization
    assert_equal @object.message_id, @message_id, "The object did not initialized correctly"
  end

  def test_soap_attribute_representation
    soap_object = @object.to_soap
    assert_not_nil soap_object.inspect,"The object should have a soap representation"
    assert_equal soap_object.extraattr[:id] ,@message_id , "Error the object and the soap representation differs "
  end

  def test_element_initialization
    assert_equal @object.subject, @subject, "The object did not initialized correctly"
  end

  def test_soap_element_representation
    soap_object = @object.to_soap
    soap_object.each{ |element,data| assert_equal data.text, @subject , "Error, the element subjects differs" if element == "su" }
  end

  def test_container_initialization
    @address = "test@test.es"
    @display_name = "Foo, Bar."
    assert_raises ArrayExpectedError do
      Zimbra::Message.new(:addresses => "TEST")
    end

    address = Zimbra::Address.new(:address => @address,:display_name => @display_name)

    @object = Zimbra::Message.new(:addresses => [address])
    assert_equal @object.addresses[0],address, "Error, addresses differ after initialization"
    @object.to_soap.each{ |element,data| assert_equal data.extraattr[:a], @address, "Error, the soap representaion of the container is wrong" if element == "e" }
  end

end
