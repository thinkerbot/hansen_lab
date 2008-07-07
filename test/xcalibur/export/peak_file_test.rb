require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'xcalibur/export/peak_file'

class Xcalibur::Export::PeakFileTest < Test::Unit::TestCase
  include Xcalibur::Export
  
  #
  # initialize test
  #
  
  def test_initialize
    p = PeakFile.new
    assert_equal([], p.desc)
    assert_equal({}, p.headers)
    assert_equal([], p.data)
  end
  
  #
  # parse test
  #
  
  SAMPLE = %Q{SPECTRUM - MS
GSE_T29K_080703143635.raw
ITMS + c ESI Full ms [300.00-2000.00]
Scan #: 11
RT: 0.07
Data points: 1490
Mass	Intensity
300.516479	2000.0
301.392487	1000.0
302.465759	3000.0
}
  
  def test_parse
    p = PeakFile.parse(SAMPLE)
    assert_equal([
      "SPECTRUM - MS", 
      "GSE_T29K_080703143635.raw", 
      "ITMS + c ESI Full ms [300.00-2000.00]"
    ], p.desc)
    
    assert_equal({
      "Scan #" => "11", 
      "RT" => "0.07", 
      "Data points" => "1490"
    }, p.headers)
    
    assert_equal([
      [300.516479,	2000.0],
      [301.392487,	1000.0],
      [302.465759,	3000.0]
    ], p.data)
  end
  
  #
  # to_s test
  #
  
  def test_to_s_reconstructs_peak_file
    assert_equal SAMPLE, PeakFile.parse(SAMPLE).to_s("\n")
  end
  
end