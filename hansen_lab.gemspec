Gem::Specification.new do |s|
  s.name = "hansen_lab"
  s.version = "0.1.0"
  s.author = "Simon Chiang"
  s.email = "simon.a.chiang@gmail.com"
  s.homepage = "http://github.com/bahuvrihi/hansen_lab/wikis"
  s.platform = Gem::Platform::RUBY
  s.summary = "Code developed for use in the Hansen Lab"
  s.require_path = "lib"
  s.has_rdoc = true
  s.add_dependency("tap", ">= 0.12")
  s.add_dependency("sample_tasks", ">= 0.11")
  s.add_dependency("ms-xcalibur", ">= 0.1.0")
  s.add_dependency("ms-mascot", ">= 0.1.0")
  s.add_dependency("hpricot", ">= 0.6")
  s.rdoc_options.concat %W{--main README -S -N --title Hansen\sLab}
  
  s.extra_rdoc_files = %W{
    README
    MIT-LICENSE
  }
  
  # list the files you want to include here. you can
  # check this manifest using 'rake :print_manifest'
  s.files = %W{
    cmd/search_raw.rb
    lib/hansen_lab/tasks/align_columns.rb
    lib/hansen_lab/tasks/align_mod.rb
    lib/hansen_lab/tasks/flag_row.rb
    lib/hansen_lab/tasks/extract_peaks.rb
    tap.yml
  }
end