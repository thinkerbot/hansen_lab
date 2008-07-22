require 'xcalibur/export/peak_file'

module Xcalibur
  module Export
    # :startdoc::manifest adds graph data to an exported peak file
    # Peakify adds points to signify the relative intensity 
    # (ie the rounded intensity/max_intensity) of peaks in 
    # an exported peak list.  This can be useful as a visual aid. 
    #
    #   [a_sample_result.txt]
    #   SPECTRUM - MS
    #   GSE_T29K_080703143635.raw
    #   ITMS + c ESI Full ms [300.00-2000.00]
    #   Scan #: 11
    #   RT: 0.07
    #   Data points: 1490
    #   Mass	Intensity
    #   300.516479	2000.0	.................................
    #   301.392487	1000.0	.................
    #   302.465759	3000.0	..................................................
    #   ...
    #
    # Options can be specified to filter out points within a
    # range of relative intensities.  Peakify can handle exported 
    # peak lists from Xcalibur Qual  Browser (v 2.0).
    #
    class Peakify < Tap::FileTask
    
      config :point_char, '.'           # a character used for each intensity point
      config :min, 0, &c.num            # min relative intenisty
      config :max, 100, &c.num          # max relative intenisty
      config :sort, false, &c.flag      # sort by intensity

      def process(filepath)
        target = app.filepath(:data, "peak_#{File.basename(filepath)}" )
        prepare(target) 
        
        # now perform the task...
        peak_file = PeakFile.parse File.read(filepath)
        max_intensity = peak_file.data.inject(0) do |max, (mz, intensity)|
          intensity > max ? intensity : max
        end
        
        range = min..max
        peak_file.data = peak_file.data.collect do |(mz, intensity)|
          percent = (intensity / max_intensity * 100)
          next unless range.include?(percent)
          
          [mz, intensity, point_char * percent.round]
        end.compact
        
        if sort
          peak_file.data = peak_file.data.sort_by do |(mz, intensity)|
            intensity
          end.reverse
        end
        
        File.open(target, "wb") do |file|
          file << peak_file.to_s
        end
        
        target
      end
      
    end
  end
end