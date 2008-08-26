require 'ms/data_explorer/format/ascii'
require 'ms/support/binary_search'

module HansenLab
  module Tasks
    # HansenLab::Tasks::ExtractPeaks::manifest extract peaks from an ascii file
    class ExtractPeaks < Tap::FileTask
      include Ms::Support::BinarySearch
      
      config :masses, [], &c.array
      config :charge, 1, &c.integer          
      config :output_file, 'results.txt', &c.string       
      
      config :tol, 100, &c.num                 # ppm tolerance for peak selection
      config :min_intensity, 5, &c.num       # minimum percent intensity
      
      def range_mzs_in_tol(mzs, mz, tol=0)
        min = mz-tol
        max = mz+tol
        search_range(mzs) do |x|
          case
          when x < min then -1
          when x > max then 1
          else 0
          end
        end
      end
 
      def process(*sources)
        results = sources.collect do |source|
          check_terminate
          
          log_basename :read, source
          spectrum = Ms::DataExplorer::Format::Ascii.parse(File.read(source))
          min = spectrum.data[1].max * min_intensity / 100
          
          sums = masses.collect do |mass|
            target = mass
            sum = 0
          
            loop do
              range = range_mzs_in_tol(spectrum.data[0], target, target * tol / 1e6)
              peaks = spectrum.data.unresolved_data[range].sort_by {|mz, intensity| intensity }

              break if peaks.empty? || peaks[-1][1] < min
              sum += peaks[-1][1]
              target += 1.0/charge
            end
            
            sum
          end
          
          sums.unshift(File.basename(source))
        end

        headers = [""]
        masses.each do |mass|
          headers << mass
        end

        results.unshift(headers)
        
        prepare(output_file)
        File.open(output_file, "w") do |file|
          log_basename :write, output_file
          file << results.collect {|row| row.join("\t") }.join("\n")
        end
        
        results
      end
    end 
  end
end