require File.join(File.dirname(__FILE__), 'tap_test_helper.rb') 
require 'align_columns'

class AlignColumnsTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_align_columns
    t = AlignColumns.new 
    assert_files do |input_files|
      target = method_filepath(:output, "align.txt")
      t.enq(target, *input_files)
      
      with_config { app.run }
      app.results(t)
    end
  end
  
  def test_align_columns_with_header
    t = AlignColumns.new nil, :header_row => true, :sort_column => 'SORT'
    assert_files do |input_files|
      target = method_filepath(:output, "align.txt")
      t.enq(target, *input_files)
      
      with_config { app.run }
      app.results(t)
    end
  end
end