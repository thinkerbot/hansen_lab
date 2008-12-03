require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'hansen_lab/tasks/extract_peaks'

class HansenLab::Tasks::ExtractPeaksTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  # def test_extract_peaks
  #   t = HansenLab::Tasks::ExtractPeaks.new 
  #   assert_files do |input_files|
  #     input_files.each do |source|
  #       target = method_root.filepath(:output, 'result.yml') 
  #       t.enq(source, target)
  #     end
  #   
  #     app.run
  #     app.results(t)
  #   end
  # end
  
end