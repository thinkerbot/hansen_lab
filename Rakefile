require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

# tasks
desc 'Default: Run tests.'
task :default => :test

desc 'Run tests.'
Rake::TestTask.new(:test) do |t|
  
  # Here the current load paths are used to define the load
  # paths in the test.  This is convenient for development 
  # but doesn't have to be here.  Note the patch is to
  # allow spaces in the lib paths, as you find on Windows.
  require 'tap/patches/rake/testtask'
  t.libs = $: + ['lib']
  
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = true
end

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  # options to specify TDoc
  require 'tap/support/tdoc'
  rdoc.template = 'tap/support/tdoc/tdoc_html_template' 
  rdoc.options << '--fmt' << 'tdoc'
  
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = '.'
  rdoc.template = 'tap/support/tdoc/tdoc_html_template' 
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('ReadMe.txt')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

#
# Gem specification
#

spec = Gem::Specification.new do |s|
  s.name = "hansen_lab"
  s.version = "0.0.1"
  s.author = "Simon Chiang"
  s.email = "simon.chiang@uchsc.edu"
  s.homepage = "http://github.com/bahuvrihi/hansen_lab/tree"
  s.platform = Gem::Platform::RUBY
  s.summary = "Add Description"
  s.files = Dir.glob("{test,lib}/**/*") + ["Rakefile", "ReadMe.txt", "tap.yml"]
  s.require_path = "lib"
  s.test_file = "test/tap_test_suite.rb"
  
  s.has_rdoc = true
  s.extra_rdoc_files = ["ReadMe.txt"]
  s.add_dependency("tap", ">= 0.9.1")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end