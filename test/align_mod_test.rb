require File.join(File.dirname(__FILE__), 'tap_test_helper.rb') 
require 'align_mod'

class AlignModTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_align_mod
    t = AlignMod.new nil, :mod_numbers => [4], :output_col_sep => '|',  :output_line_format => '|%s|', :output_empty_cell => '.'
    assert_files do |input_files|
      input_files.each {|file| t.enq(file)}
      
      with_config :directories => {:data => 'output'} do 
        app.run
      end
      
      app.results(t)
    end
  end
  
end