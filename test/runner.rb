$:.unshift(File.dirname(__FILE__))

require 'test/unit/ui/console/testrunner'
require 'test/unit/testsuite'
require 'test_message'
require 'test_folder'
require 'test_conversation'
require 'test_soap'
require 'test_account'

class TestZimbra
  def self.suite
    suite = Test::Unit::TestSuite.new
    suite << TestSoap.suite
    suite << TestMessage.suite
    suite << TestFolder.suite
    suite << TestConversation.suite
    suite << TestAccount.suite
    return suite
  end
end


Test::Unit::UI::Console::TestRunner.run(TestZimbra)

