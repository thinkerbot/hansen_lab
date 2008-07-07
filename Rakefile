require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

# tasks
desc 'Default: Run tests.'
task :default => :test

desc 'Run tests.'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = true
end

#
# Gem specification
#

gemspec = Gem::Specification.new do |s|
  s.name = "."
  s.version = "0.0.1"
  s.author = "Your Name Here"
  #s.email = "your.email@pubfactory.edu"
  #s.homepage = "http://rubyforge.org/projects/gemname/"
  s.platform = Gem::Platform::RUBY
  s.summary = "Add Description"
  s.require_path = "lib"
  s.test_file = "test/tap_test_suite.rb"
  #s.rubyforge_project = "gemname"
  s.has_rdoc = true
  s.add_dependency("tap", ">= 0.10.0")
  s.extra_rdoc_files = %w{ ReadMe.txt }
  s.files = Dir.glob("{test,lib}/**/*") + %w{ Rakefile ReadMe.txt tap.yml }
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
end

desc 'Prints the gemspec manifest.'
task :print_manifest do
  # collect files from the gemspec, labeling 
  # with true or false corresponding to the
  # file existing or not
  files = gemspec.files.inject({}) do |files, file|
    files[File.expand_path(file)] = [File.exists?(file), file]
    files
  end
  
  # gather non-rdoc/pkg files for the project
  # and add to the files list if they are not
  # included already (marking by the absence
  # of a label)
  Dir.glob("**/*").each do |file|
    next if file =~ /^(rdoc|pkg)/ || File.directory?(file)
    
    path = File.expand_path(file)
    files[path] = ["", file] unless files.has_key?(path)
  end
  
  # sort and output the results
  files.values.sort_by {|exists, file| file }.each do |entry| 
    puts "%-5s : %s" % entry
  end
end

#
# Documentation tasks
#

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  # configured to generate TDoc documentation ...
  # to revert, comment out the template and
  # the --fmt and tdoc options.
  require 'tap/support/tdoc/config_attr'

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = '.'
  rdoc.template = 'tap/support/tdoc/tdoc_html_template' 
  rdoc.options << '--line-numbers' << '--inline-source' << '--fmt' << 'tdoc'
  rdoc.rdoc_files.include( gemspec.extra_rdoc_files )
  rdoc.rdoc_files.include( gemspec.files.select {|file| file =~ /^lib.*\.rb$/} )
end
