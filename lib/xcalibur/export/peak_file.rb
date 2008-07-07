module Xcalibur
  module Export
  
    # A simple representation of a peak file exported from Xcalibur Qual 
    # Browser (v 2.0).  The expected format of a peak file is as shown below:
    #
    #  [peak_file.txt]
    #   SPECTRUM - MS
    #   GSE_T29K_080703143635.raw
    #   ITMS + c ESI Full ms [300.00-2000.00]
    #   Scan #: 11
    #   RT: 0.07
    #   Data points: 1490
    #   Mass	Intensity
    #   300.516479	2000.0
    #   301.392487	1000.0
    #   302.465759	3000.0
    #   ...
    #
    # Any headers matching the pattern 'key: value' will be parsed as a 
    # header, while other lines (ex: SPECTRUM - MS) are parsed into the
    # description.
    #
    class PeakFile
      
      class << self
        
        # Parses the input string into a PeakFile
        def parse(str)
          peak_file = PeakFile.new
          mode = :header
          str.each_line do |line|
            case mode
            when :header
            
              case line
              when /^(.*?): (.*)$/
                peak_file.headers[$1] = $2
              when /Mass\sIntensity/
                mode = :data
              else
                peak_file.desc << line.strip
              end
            
            when :data
              peak_file.data << line.split(/\s/).collect {|mz| mz.to_f }
            end
          end
          
          peak_file
        end
      end
      
      # The order of headers observed in export files
      HEADER_ORDER = [
        "Scan #",
        "RT",
        "Mass defect",
        "Data points"
      ]
      
      # An array of description lines
      attr_accessor :desc
      
      # A hash of headers
      attr_accessor :headers
      
      # An array of (mz, intensity) values
      attr_accessor :data
      
      def initialize(desc=[], headers={}, data=[])
        @desc = desc
        @headers = headers
        @data = data
      end
      
      # Recreates the peak file
      def to_s(sep="\r\n")
        lines = desc + 
        HEADER_ORDER.collect do |key|
          next nil unless headers.has_key?(key)
          "#{key}: #{headers[key]}"
        end.compact +
        ["Mass\tIntensity"] +
        data.collect do |point|
          point.join("\t")
        end
        
        lines.join(sep) + sep
      end
      
    end
  end
end