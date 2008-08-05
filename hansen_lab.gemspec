Gem::Specification.new do |s|
  s.name = "hansen_lab"
  s.version = "0.0.1"
  #s.author = "Your Name Here"
  #s.email = "your.email@pubfactory.edu"
  #s.homepage = "http://rubyforge.org/projects/hansen_lab/"
  s.platform = Gem::Platform::RUBY
  #s.summary = "Add Description"
  s.require_path = "lib"
  s.test_file = "test/tap_test_suite.rb"
  #s.rubyforge_project = "hansen_lab"
  s.has_rdoc = true
  s.add_dependency("tap", "~> 0.10.0")
  s.extra_rdoc_files = %W{
    README
    MIT-LICENSE
  }
  
  # list the files you want to include here. you can
  # check this manifest using 'rake :print_manifest'
  s.files = %W{
    tap.yml
    test/tap_test_helper.rb
    test/tap_test_suite.rb
  }
end