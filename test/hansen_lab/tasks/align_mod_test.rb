require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'hansen_lab/tasks/align_mod'

class AlignModTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  include HansenLab::Tasks
  
  def test_align_mod
    t = AlignMod.new :mod_numbers => [4], :output_col_sep => '|',  :output_line_format => '|%s|', :output_empty_cell => '.'
    assert_files do |input_files|
      input_files.each do |path|
        t.enq(method_filepath(:output, t.basename(path, '.txt')), path)
      end
      
      app.run
      app.results(t)
    end
  end
  
end