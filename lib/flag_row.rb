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
class FlagRow < Tap::FileTask

  config :row_sep, "\n", &c.string       # row delimiter
  config :col_sep, "\t", &c.string       # column delimiter
  
  config :check_column, 0, &c.integer    # the column to check
  config :pattern, /./, &c.regexp        # the matching pattern
  config :flag, 1                        # the flag value
  config :no_flag, 0                     # the not-flagged value

  # process defines what the task does; use the
  # same number of inputs to enque the task
  # as specified here
  def process(target, source)
    
    log_basename :process, source
    
    # load the data and split into rows
    rows = File.read(source).split(row_sep)
    
    unless check_column.to_s =~ /^\d+$/
      headers = rows.first.split(col_sep)
      self.check_column = headers.index(check_column)
      
      raise "could not identify column: #{check_column}" if check_column == nil
    end
    
    # iterate over the rows, 
    # add a flag signaling a match to the pattern,
    # and collect the results
    rows.collect! do |row|
      columns = row.split(col_sep)
      columns << (columns[check_column] =~ pattern ? flag : no_flag)
      
      # join the columns back up
      columns.join(col_sep)
    end
    
    # join the rows back up
    results = rows.join(row_sep)
    
    # prepare the target file and dump the results
    prepare(target) 
    File.open(target, "wb") do |file|
      file << results
    end
    
    target
  end
  
end