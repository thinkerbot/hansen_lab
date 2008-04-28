module HansenLab
  class NormalTable
    class << self
      
      # Parses the string into an array of table data, using the
      # specified row and column delimiters.
      def parse_rows(string, row_delimiter=/\r?\n/, col_delimiter="\t")
        string.split(row_delimiter).collect do |row|
          row.split(col_delimiter)
        end
      end
      
    end
    
    # the rows padded to a common number of columns using default_value
    attr_reader :rows
    
    # the padding value for rows
    attr_reader :default_value
  
    # the length of column in the normalized table
    attr_reader :n_columns
    
    def initialize(rows, default_value=nil)
      @default_value = default_value
      @n_columns = rows.inject(0) do |max, column|
        max > column.length ? max : column.length
      end
      
      @rows = rows.collect do |row|
        row + Array.new(n_columns - row.length, default_value)
      end
    end
    
    # Returns an array of n_columns length and default_value
    def blank_row
      Array.new(n_columns, default_value)
    end
    
  end
end