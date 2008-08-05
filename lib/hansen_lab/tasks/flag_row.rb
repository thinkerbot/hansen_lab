require 'tap/tasks/table_task'
 
module HansenLab
  module Tasks
  
    # :startdoc::manifest flag rows in a table
    # Flags rows in a table that have a column matching a specified 
    # regexp pattern.  You can specify the column to check by name 
    # (in which case the first row is assumed to be headers) or by 
    # number (starting with column 0).  Patterns are matched without
    # regard to case.
    #
    # Examples:
    #   # match the 'accession' column with entries like 'mouse'
    #   % tap run -- flag_row FILE --column accession --pattern mouse
    #
    #   # match the first (ie index == 0) column with entries
    #   # like 'a mouse' or 'a human'
    #   % tap run -- flag_row FILE --column 0 --pattern "a mouse|a human"
    #
    class FlagRow < Tap::Tasks::TableTask
    
      config :check_column, 0, &c.yaml(String, Integer)    # the column to check
      config :pattern, /./, &c.regexp                      # the matching pattern
      config :flag, 1                                      # the flag value
      config :no_flag, 0                                   # the not-flagged value
      
      def flag_rows(table)
        column_index = case check_column
        when String then table.headers.index(check_column)
        when Integer then check_column
        else nil
        end

        if column_index == nil  || table.n_columns <= column_index
          raise "could not identify column: #{check_column}"
        end
        
        # iterate over the rows and add a flag signaling
        # a match to the pattern
        table.data.collect! do |row|
          row << (row[column_index] =~ pattern ? flag : no_flag)
        end
        
        table
      end
      
      # process defines what the task does; use the
      # same number of inputs to enque the task
      # as specified here
      def process(target, source)
        
        log_basename :process, source
        
        # load the data and split into rows
        table = parse_table(File.read(source))
        flag_rows(table)

        # prepare the target file and dump the results
        prepare(target) 
        File.open(target, "wb") do |file|
          file << table.join(row_sep, col_sep, header_row)
        end
        
        target
      end
    end
  end
end