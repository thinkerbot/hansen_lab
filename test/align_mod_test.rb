require File.join(File.dirname(__FILE__), 'tap_test_helper.rb') 
require 'align_mod'

class AlignModTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_align_mod
    # assert_expected_result_files provides a list of the
    # files in 'align_mod/test_align_mod/input'
    # and expects that the block makes a list of output
    # files in 'align_mod/test_align_mod/output'
    #
    # These outputs are compared by content with the 
    # files in 'align_mod/test_align_mod/expected'
    # 
    # The output directory is cleaned up by default.  To 
    # preserve it, set the KEEP_OUTPUTS env variable:
    #
    #   % rake test keep_outputs=true
    
    t = AlignMod.new 
    assert_files do |input_files|
      input_files.each {|file| t.enq(file)}
      
      with_config :directories => {:data => 'output'} do 
        app.run
      end
      
      app.results(t)
    end
  end
  
end