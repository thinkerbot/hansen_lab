# == Description
# Aligns the data across multiple files.  Takes a list of tab-delimited 
# input files.
#
# === Usage
#   % tap run -- align_columns TARGET_FILE, INPUT_FILES...
#
class AlignColumns < Tap::FileTask

  config :row_delimiter, "\n"           # row delimiter
  config :col_delimiter, "\t"            # column delimiter
  config :blank_value, ""                # the blank value

  def sorting_value(row)
    row.first  
  end
  
  def process(target, *filepaths)
    
    # load the table data
    tables = filepaths.collect do |filepath|
      log_basename :align, filepath
      
      rows = HansenLab::NormalTable.parse_rows(File.read(filepath), row_delimiter, col_delimiter)
      HansenLab::NormalTable.new(rows, blank_value)
    end
    
    # hash rows by the sorting keys
    sorting_keys = []
    key_hashes = tables.collect do |table|
      hash = {}
      table.rows.each_with_index do |row, i|
        key = sorting_value(row)
        sorting_keys << key
        (hash[key] ||= []) << i
      end
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
      # print header
      header = []
      filepaths.each_with_index do |filepath, i|
        table = tables[i]
        unless table.n_columns == 0
          array = table.blank_row
          array[0] = "# #{File.basename(filepath)}"
          header << array.join(col_delimiter)
        end
      end
      file.print header.join(col_delimiter * 2) + row_delimiter
      
      sorting_keys.each do |key|
        key_rows = []
        tables.each_with_index do |table, index|
          row_index = key_hashes[index][key]
          rows = row_index.collect do |i| 
            (i == nil ? table.blank_row : table.rows[i]).join(col_delimiter)
          end
          
          key_rows << rows
        end

        key_rows.transpose.collect do |row|
          file.print row.join(col_delimiter * 2) + row_delimiter
        end
      end
    end
    
    target
  end
  
end