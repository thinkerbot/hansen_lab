require 'tap/tasks/table_task'
 
module HansenLab
  module Tasks
  
    # :startdoc::manifest align mascot peptide ids at a modification
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
    class AlignMod < Tap::Tasks::TableTask
      
      config :mod_numbers, [1], :arg_name => '[1, 2, 3]', &c.array   # the alignment modification number
      
      config :output_empty_cell, "", &c.string      # the content for empty output cells
      config :output_line_format, "%s", &c.string   # the format string for the output lines
      config :output_col_sep, "\t", &c.string       # the output column delimiter
      config :default_value, "", &c.string                  # a default string value for empty cells  
      
      def format_row(data)
        output_line_format % data.join(output_col_sep)
      end
      
      def process(target, source)
    
        table = parse_table( File.read(source) )
        
        prepare(target) 
        File.open(target, "wb") do |file|
          
          # handle the header row.  Note that the headers need to be
          # moved around a little to conform to the output format.
          if header_row
            file.puts format_row(["", "", ""] + table.headers[2..-1])
          end
          
          sequence_locations = {}
          table.data.each do |line|
            seq, locator, *identifiers = line

            # checks
            unless locator =~ /^\d\.(\d+)\.\d$/ && seq.length == $1.length
              raise "could not split line correctly: #{line}"
            end
            
            locator = $1
            locations = sequence_locations[seq] ||= []
            split_locations = [] 
            0.upto(locator.length-1) do |index|
              if mod_numbers.include?(locator[index, 1].to_i)
                unless locations.include?(index)
                  split_locations << index
                  locations << index
                end
              end
            end
            
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
  end
end