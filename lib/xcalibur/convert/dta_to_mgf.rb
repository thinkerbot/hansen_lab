require 'constants'

module Xcalibur
  module Convert
    # :startdoc::manifest convert dta files to mgf format
    # Converts a set of .dta files (Sequest format) into an .mgf (Mascot format) 
    # file.  The conversion is straightforward.  
    #
    # dta format:
    #   [input_file.dta]
    #   353.128 1 
    #   85.354 2.2
    #   87.302 2.8
    #   ...
    #
    # mgf format:
    #   [output_file.mgf]
    #   BEGIN IONS
    #   TITLE=input_file
    #   CHARGE=1
    #   PEPMASS=<calculated>
    #   85.354 2.2
    #   87.302 2.8
    #   ...
    #   END IONS
    #
    # The first line of the dta file specifies the M+H (mh) and charge state (z) of 
    # the  precursor ion.  To convert this to PEPMASS, use (mh + (z-1) * H)/ z) where
    # H is the mass of a proton, ie hydrogen - electron.  The mass of a proton is
    # calculated from the {constants}[bioactive.rubyforge.org/constants] gem to be 
    # ~ 1.007276 Da
    #
    class DtaToMgf < Tap::FileTask
      include Constants::Libraries
      
      # Returns the unrounded mass of a proton (H - e) as calculated
      # from the {constants}[bioactive.rubyforge.org/constants] gem.
      config :proton_mass, Element['H'].mass - Particle['Electron'].mass, &c.num_or_nil        # allows specification of an alternate proton mass
      
      def process(output_file, *inputs)
        return output_file if inputs.empty?
        
        dta_files = inputs.collect do |file| 
          if File.directory?(file)
            Dir.glob(File.expand_path(File.join(file, "*.dta")))
          else
            raise "Not a .dta file: #{file}" unless file =~ /\.(dta)$/
            file
          end
        end
        
        prepare(output_file) 
        File.open(output_file, "wb") do |target|
          h = proton_mass
          
          dta_files.flatten.each do |file|
            #log_basename(:merging, file)
            lines = File.read(file).split(/\r?\n/)
            
            # get the mh and z
            mh, z = lines.shift.split(/\s+/)
            mh = mh.to_f
            z = z.to_i
            
            # add a trailing empty line
            lines << ""
            
            # make the output
            target << %Q{BEGIN IONS
TITLE=#{File.basename(file)}
CHARGE=#{z}+
PEPMASS=#{(mh + (z-1) * h)/ z}
#{lines.join("\n")}
END IONS

}
          end
        end
        log(:made, output_file)
        
        output_file
      end
      
    end
  end
end
