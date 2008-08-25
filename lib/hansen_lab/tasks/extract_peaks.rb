require 'ms/data_explorer/format/ascii'

module HansenLab
  module Tasks
    # HansenLab::Tasks::ExtractPeaks::manifest <replace with manifest summary>
    # <replace with command line description>
    
    class ExtractPeaks < Tap::FileTask
      
      config :masses, [], &c.array
      config :charges, [], &c.array
      
      config :tol, 0, &c.num
      config :min_intensity, 5, &c.num  # minimum percent intensity
      
      def process(*sources)
        results = {}
        results['sources'] = sources
        
        spectra = sources.collect do |source|
          check_terminate
          
          log_basename :extract, source
          s = Ms::DataExplorer::Format::Ascii.parse(File.read(source))
          min = s.spectrum.intensities.max * min_intensity / 100
          
          [s, min]
        end

        masses.each do |original_mass|
          results[original_mass] = spectra.collect do |s, min|
            mass = original_mass
            sum = 0
          
            loop do
              range = s.spectrum.range_mzs_in_tol(mass, mass * tol / 1e6)
              peaks = s.spectrum.data[range].sort_by do |mz, intensity|
                intensity
              end

              break if peaks.empty? || peaks[-1][1] < min
              sum += peaks[-1][1]
              mass += 1.0/charge
            end
            
            sum
          end
        end
        
        results
      end
    end 
  end
end