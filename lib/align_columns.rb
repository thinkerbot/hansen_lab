# startdoc::manifest align table data across multiple files
# Aligns the table data across multiple files.  Takes a list of tab-delimited 
# input files.
#
class AlignColumns < Tap::FileTask

  config :row_sep, "\n", &c.string     # row delimiter
  config :col_sep, "\t", &c.string     # column delimiter
  config :blank_value, "", &c.string   # the blank value
  
  config :header_row, false, &c.flag   # specifies handling of header rows
  config :sort_column, 0, &c.yaml      # specifies the sort column, index or name
  
  def format_row(data)
    data.join(col_sep * 2) + row_sep
  end
  
  def process(target, *filepaths)

    # load the table data
    tables = filepaths.collect do |filepath|
      log_basename :align, filepath
      
      rows = HansenLab::NormalTable.parse_rows(File.read(filepath), row_sep, col_sep)
      HansenLab::NormalTable.new(rows, :default_value => blank_value, :header_row => header_row)
    end
    
    # hash rows by the sorting keys
    sorting_keys = []
    key_hashes = tables.collect do |table|
      
      keys = case sort_column
      when Integer then table.rows.collect {|row| row[sort_column] }
      else table.column(sort_column)
      end
      
      hash = {}
      keys.each_with_index do |key, i|
        (hash[key] ||= []) << i
      end
      sorting_keys.concat(keys)
      
      hash
    end
    
    # sort, omitting empty keys
    sorting_keys = sorting_keys.uniq.sort.delete_if do |key|
      key.strip.empty?
    end
    
    # normalize the number of rows for each key, cross table
    sorting_keys.each do |key|
      max = key_hashes.inject(0) do |max, hash|
        row_index = (hash[key] ||= [])
        row_index.length > max ? row_index.length : max
      end
      
      key_hashes.each do |hash|
        row_index = hash[key]
        row_index.concat Array.new(max - row_index.length, nil)
      end
    end
    
    # prepare the target file and dump the results
    prepare(target) 
    File.open(target, "wb") do |file|
      # print file header
      header = []
      filepaths.each_with_index do |filepath, i|
        table = tables[i]
        unless table.n_columns == 0
          array = table.blank_row
          array[0] = "# #{File.basename(filepath)}"
          header << array.join(col_sep)
        end
      end
      file.print format_row(header)
      
      # print header if applicable
      if header_row
        row = tables.collect {|table| table.header_row.join(col_sep)}
        file.print format_row(row)
      end
      
      sorting_keys.each do |key|
        key_rows = []
        tables.each_with_index do |table, index|
          row_index = key_hashes[index][key]
          rows = row_index.collect do |i| 
            (i == nil ? table.blank_row : table.rows[i]).join(col_sep)
          end
          
          key_rows << rows
        end

        key_rows.transpose.collect do |row|
          file.print format_row(row)
        end
      end
    end
    
    target
  end
  
end