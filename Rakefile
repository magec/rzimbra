require 'rubygems'
 
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'


#
# DOCUMENTATION

Rake::RDocTask.new do |rd|
 
  rd.main = 'README.rdoc'
  rd.rdoc_dir = 'html/rzimbra'
  rd.rdoc_files.include(
    'README.rdoc',
#    'CHANGELOG.txt',
#    'LICENSE.txt',
#    'CREDITS.txt',
    'lib/**/*.rb')
  rd.title = 'rzimbra rdoc'
  rd.options << '-N' # line numbers
  rd.options << '-S' # inline source
end
 
task :rrdoc => :rdoc do
  FileUtils.cp('doc/rdoc-style.css', 'html/rzimbra/')
end