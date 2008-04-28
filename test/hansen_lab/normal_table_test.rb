require File.join(File.dirname(__FILE__), '../tap_test_helper.rb') 
require 'hansen_lab/normal_table'

class NormalTableTest < Test::Unit::TestCase
  include HansenLab
  
  #
  # parse_rows test 
  #
  
  def test_parse_rows_splits_a_string_into_rows_and_columns
    assert_equal [], NormalTable.parse_rows("")
    assert_equal [["a1", "b1", "c1"],["", "b2"],["a3", "", "c3"]], NormalTable.parse_rows("a1\tb1\tc1\n\tb2\t\t\na3\t\tc3")
  end
  
  def test_parse_rows_uses_the_specified_delimiters
    assert_equal [["a1", "b1", "c1"],["", "b2"],["a3", "", "c3"]], NormalTable.parse_rows("a1.b1.c1!.b2..!a3..c3", "!", ".")
  end
  
  
  #
  # initialization tests
  #
  
  def test_n_columns_is_the_length_of_the_longest_row
    t = NormalTable.new []
    assert_equal 0, t.n_columns
    
    t = NormalTable.new [[], [], []]
    assert_equal 0, t.n_columns
    
    t = NormalTable.new [[1, 2], [], [1, 2, 3]]
    assert_equal 3, t.n_columns
  end
  
  def test_rows_are_normalized_to_n_columns_length
    t = NormalTable.new []
    assert_equal [], t.rows
    
    t = NormalTable.new [[], [], []]
    assert_equal [[], [], []], t.rows
    
    t = NormalTable.new [[1, 2], [], [1, 2, 3]]
    assert_equal [[1, 2, nil], [nil, nil, nil], [1, 2, 3]], t.rows
  end
  
  def test_normal_table_normalizes_input_rows_with_default_value
    t = NormalTable.new [[1, 2], [], [1, 2, 3]], :default_value => :default
    assert_equal [[1, 2, :default], [:default, :default, :default], [1, 2, 3]], t.rows
    assert_equal :default, t.default_value
  end
  
  def test_header_row_is_shifted_off_if_header_row_option_is_true
    t = NormalTable.new [['a', 'b', 'c'], [1, 2], [], [1, 2, 3]], :header_row => true
    assert_equal ['a', 'b', 'c'], t.header_row
    assert_equal [[1, 2, nil], [nil, nil, nil], [1, 2, 3]], t.rows
  end

  def test_header_row_is_blank_row_if_header_row_option_is_false
    t = NormalTable.new [['a', 'b', 'c'], [1, 2], [], [1, 2, 3]], :header_row => false
    assert_equal [nil, nil, nil], t.header_row
    assert_equal [['a', 'b', 'c'], [1, 2, nil], [nil, nil, nil], [1, 2, 3]], t.rows
  end
  
  def test_header_row_raises_error_if_no_header_row_is_available
    assert_raise(RuntimeError) { NormalTable.new [], :header_row => true }
  end
  
  #
  # blank_row test
  #
  
  def test_blank_row_is_an_array_of_n_col_length_with_default_value
    t = NormalTable.new []
    assert_equal [], t.blank_row
    
    t = NormalTable.new [[], [], []]
    assert_equal [], t.blank_row
    
    t = NormalTable.new [[1, 2], [], [1, 2, 3]]
    assert_equal [nil, nil, nil], t.blank_row
    
    t = NormalTable.new [[1, 2], [], [1, 2, 3]], :default_value => :default
    assert_equal [:default, :default, :default], t.blank_row
  end
  
  #
  # column test
  #
  
  def test_colum_returns_column_data_for_the_specified_column
    t = NormalTable.new [['a', 'b', 'c'], [1, 2], [], [1, 2, 3]], :header_row => true
    assert_equal [1,nil,1], t.column('a')
    assert_equal [nil,nil,3], t.column('c')
  end
  
  def test_colum_raises_error_when_column_cannot_be_found
    t = NormalTable.new [['a', 'b', 'c'], [1, 2], [], [1, 2, 3]], :header_row => true
    assert_raise(RuntimeError) { t.column('d') }
    
    t = NormalTable.new [['a', 'b', 'c'], [1, 2], [], [1, 2, 3]], :header_row => false
    assert_raise(RuntimeError) { t.column('a') }
  end
end
  