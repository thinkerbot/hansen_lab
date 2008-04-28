require File.join(File.dirname(__FILE__), 'tap_test_helper.rb') 
require 'align_columns'

class AlignColumnsTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_align_columns
    # assert_expected_result_files provides a list of the
    # files in 'align_columns/test_align_columns/input'
    # and expects that the block makes a list of output
    # files in 'align_columns/test_align_columns/output'
    #
    # These outputs are compared by content with the 
    # files in 'align_columns/test_align_columns/expected'
    # 
    # The output directory is cleaned up by default.  To 
    # preserve it, set the KEEP_OUTPUTS env variable:
    #
    #   % rake test keep_outputs=true
    
    t = AlignColumns.new 
    assert_files do |input_files|
      target = method_filepath(:output, "align.txt")
      t.enq(target, *input_files)
      
      with_config { app.run }
      app.results(t)
    end
  end
  
end