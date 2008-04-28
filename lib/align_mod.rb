# == Description
# Aligns Mascot peptide identifications along a modification boundary.
#
# For example:
#   [input.txt]
#   AAAQAAA 0.0004000.0 first
#   QBBBBBQ 0.4000004.0 second 
#
# Becomes:
#   [input.align]
#   |AAA|Q|AAA|first|
#   |.|Q|BBBBBQ|second (1)|
#   |QBBBBB|Q|.|second (2)|
#
# Extra fields can be present in the input file, they will be carried forward
# to the result file.  If a sequence has multiple modifications, each will be
# listed in the result, as above.
#
# Note that while the results don't seem terribly well aligned here, they can
# be turned into a table by using RedCloth (for example by posting the result
# as a message to Basecamp), or you can modify the output with the configs.
#
# === Usage
#   tap run -- align_mod [options] INPUT_FILE
#
class AlignMod < Tap::FileTask
  
  config :header_row, false                     # should be true if there is a header row
  config :input_column_delimiter, "\t"    # the input column delimiter
  config :mod_numbers, [3,4]                 # the alignment modification number
  
  config :output_empty_cell, "."             # the content for empty output cells
  config :output_line_format, "|%s|"       # the format string for the output lines
  config :output_column_delimiter, "|"   # the output column delimiter
  
  def format_row(data)
    output_line_format % data.join(output_column_delimiter)
  end
  
  def process(filepath)

    target = app.filepath(:data, basename(filepath, '.txt') )
    prepare(target) 
    
    array = File.read(filepath).split(/\r?\n/)
    File.open(target, "wb") do |file|
      
      # handle the header row.  Note that the headers need to be
      # moved around a little to conform to the output format.
      if header_row
        headers = ["", "", ""] + array.shift.split(input_column_delimiter)[2..-1]
        file.puts format_row(headers)
      end
      
      array.each do |line|
        seq, locator, identifier = line.split(input_column_delimiter, 3)
        identifiers = identifier.to_s.split(input_column_delimiter)
        
        # checks
        unless locator =~ /^\d\.(\d+)\.\d$/ && seq.length == $1.length
          raise "could not split line correctly: #{line}"
        end
        
        locator = $1
        split_locations = [] 
        0.upto(locator.length-1) do |index|
          split_locations << index if mod_numbers.include?(locator[index, 1].to_i)
        end
        
        log :warn, "no mods in: #{line}" if split_locations.empty?
        
        split_locations.each_with_index do |location, index|
          data = [
            seq[0...location],
            seq[location, 1],
            seq[location+1..-1],
          ] 
          data += identifiers if index == 0
          
          # modify the lead identifier to note duplicates
          data[3] = "#{identifiers[0]} (#{index + 1})" if split_locations.length > 1
          data.collect! {|str| str.empty? ? output_empty_cell : str }
          
          file.puts format_row(data)
        end
        
      end
    end
    
    target
  end
  
end