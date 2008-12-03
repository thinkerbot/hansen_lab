require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'hansen_lab/tasks/align_columns'

class AlignColumnsTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  include HansenLab::Tasks
  
  def test_align_columns
    t = AlignColumns.new 
    assert_files do |input_files|
      t.enq(method_root.filepath(:output, "align.txt"), *input_files)
      
      app.run
      app.results(t)
    end
  end
  
  def test_align_columns_with_header
    t = AlignColumns.new :header_row => true, :sort_column => 'SORT'
    assert_files do |input_files|
      t.enq(method_root.filepath(:output, "align.txt"), *input_files)
      
      app.run
      app.results(t)
    end
  end
end