Gem::Specification.new do |s| 
  s.name = "rzimbra"
  s.version = "0.0.1"
  s.author = "Jose Fernandez"
  s.email = "joseferper@gmail.com"
  s.homepage = "http://magec.es"
  s.platform = Gem::Platform::RUBY
  s.summary = "A client library for connecting to Zimbra Collaboration Suite trought SOAP protocol"
  s.files = Dir.glob("{bin,lib,examples}/**/*")# + %w(README CHANGELOG)
  s.require_paths = ["lib"]
  s.test_files = Dir.glob("{test}/**/*")
  s.has_rdoc = true
  s.add_dependency("soap4r", ">= 1.5.8")
  s.add_dependency("libxml-ruby", ">= 0.9.8")
end
