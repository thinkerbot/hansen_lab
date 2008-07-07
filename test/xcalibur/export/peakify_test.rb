require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'xcalibur/export/peakify'

class Xcalibur::Export::PeakifyTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_peakify
    t = Xcalibur::Export::Peakify.new 
    assert_files do |input_files|
      input_files.each {|file| t.enq(file)}
      
      with_config :directories => {:data => 'output'} do 
        app.run
      end
      
      app.results(t)
    end
  end
  
end