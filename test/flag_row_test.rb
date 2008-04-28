require File.join(File.dirname(__FILE__), 'tap_test_helper.rb') 
require 'flag_row'

class FlagRowTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_flag_row
    t = FlagRow.new nil, :pattern => /true/, :check_column => 1
    assert_files do |input_files|
      input_files.each {|file| t.enq(file)}
      
      with_config :directories => {:data => 'output'} do 
        app.run
      end
      
      app.results(t)
    end
  end
  
end