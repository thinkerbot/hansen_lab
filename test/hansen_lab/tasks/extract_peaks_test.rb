require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'hansen_lab/tasks/extract_peaks'

class HansenLab::Tasks::ExtractPeaksTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_extract_peaks
    # Use assert_files to test file transform tasks.  The block  
    # recieves the method input files and compares the results 
    # to the method expected files.
  
    # Generated files are often placed in method output, as it
    # is cleaned up each test.  To keep output files, set the 
    # KEEP_OUTPUTS variable:
    #   % rake test keep_outputs=true
  
    t = HansenLab::Tasks::ExtractPeaks.new 
    assert_files do |input_files|
      input_files.each do |source|
        target = method_filepath(:output, 'result.yml') 
        t.enq(source, target)
      end
    
      app.run
      app.results(t)
    end
  end
  
end