# :manifest: flag rows in a table
# Cycles through the rows in a table and adds a field indicating
# whether or not a given row matches a specified pattern.  You
# can specify the column to check by name (in which case the
# first row is assumed to be headers) or by number (starting
# with column 0).  Patterns are matched case-insensitive.
#
# Examples:
#   # match the 'accession' column with entries like 'mouse'
#   % tap run -- flag_row FILE --column=accession --pattern=mouse
#
#   # match the first (ie index == 0) column with entries
#   # like 'a mouse' or 'a human'
#   % tap run -- flag_row FILE --column=0 --pattern="a mouse|a human"
#
class FlagRow < Tap::FileTask

  config :row_delimiter, "\n"           # row delimiter
  config :col_delimiter, "\t"            # column delimiter
  
  config :check_column, 0                    # the column to check
  config :pattern, /./ do |value|           # the matching pattern
    case value
    when String then Regexp.new(value, Regexp::IGNORECASE)
    when Regexp then value
    else
      raise "cannot convert to Regexp: #{value}"
    end
  end
  
  # process defines what the task does; use the
  # same number of inputs to enque the task
  # as specified here
  def process(filepath)
    
    log_basename :process, filepath
    
    # load the data and split into rows
    rows = File.read(filepath).split(row_delimiter)
    
    unless check_column.to_s =~ /^\d+$/
      headers = rows.first.split(col_delimiter)
      self.check_column = headers.index(check_column)
      
      raise "could not identify column: #{check_column}" if check_column == nil
    end
    
    # iterate over the rows, 
    # add a flag signaling a match to the pattern,
    # and collect the results
    rows.collect! do |row|
      columns = row.split(col_delimiter)
      columns << (columns[check_column] =~ pattern ? 1 : 0)
      
      # join the columns back up
      columns.join(col_delimiter)
    end
    
    # join the rows back up
    results = rows.join(row_delimiter)
    
    # prepare the target file and dump the results
    target = app.filepath(:data, basename(filepath, ".txt"))
    prepare(target) 
    File.open(target, "wb") do |file|
      file << results
    end
    
    target
  end
  
end