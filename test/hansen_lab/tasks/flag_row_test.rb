require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'hansen_lab/tasks/flag_row'

class FlagRowTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  include HansenLab::Tasks
  
  def test_flag_row
    t = FlagRow.new :pattern => /true/, :check_column => 1
    assert_files do |input_files|
      input_files.each do |path|
        t.enq(method_filepath(:output, t.basename(path, '.txt')), path)
      end
      
      app.run
      
      app.results(t)
    end
  end
  
  def test_flag_row_with_header_row
    t = FlagRow.new :pattern => /true/, :check_column => 'value', :header_row => true
    
    assert_files do |input_files|
      input_files.each do |path|
        t.enq(method_filepath(:output, t.basename(path, '.txt')), path)
      end
      
      app.run
      
      app.results(t)
    end
  end
  
end