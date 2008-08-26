Gem::Specification.new do |s|
  s.name = "hansen_lab"
  s.version = "0.0.2"
  s.author = "Simon Chiang"
  s.email = "simon.a.chiang@gmail.com"
  s.homepage = "http://github.com/bahuvrihi/hansen_lab/wikis"
  s.platform = Gem::Platform::RUBY
  s.summary = "Code developed for use in the Hansen Lab"
  s.require_path = "lib"
  s.test_file = "test/tap_test_suite.rb"
  #s.rubyforge_project = "hansen_lab"
  s.has_rdoc = true
  s.add_dependency("tap", "~> 0.10.0")
  s.add_dependency("sample_tasks", "~> 0.10.0")
  s.extra_rdoc_files = %W{
    README
    MIT-LICENSE
  }
  
  # list the files you want to include here. you can
  # check this manifest using 'rake :print_manifest'
  s.files = %W{
    lib/hansen_lab/tasks/align_columns.rb
    lib/hansen_lab/tasks/align_mod.rb
    lib/hansen_lab/tasks/flag_row.rb
    lib/hansen_lab/tasks/extract_peaks.rb
    tap.yml
  }
end