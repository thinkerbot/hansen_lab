module Xcalibur
  module Convert
    # :startdoc::manifest convert RAW files to dta format
    # Converts a .RAW file to dta files using extract_msn.exe 
    #
    # extract_msn.exe is an Xcalibur/BioWorks tool that extracts spectra from .RAW
    # files into .dta (Sequest) format and must be installed for RawToDta to work.
    # RawToDta was developed against extract_msn version 4.0.  You can check if
    # extract_msn is installed at the default location, as well as determine the  
    # version of your executable using:
    #
    #   % tap run -- xcalibur/convert/raw_to_dta  --extract_msn_help
    #
    class RawToDta < Tap::FileTask
      config :extract_msn, 'C:\Xcalibur\System\Programs\extract_msn.exe' # the full path to the extract_msn executable
      config :first_scan, nil, &c.integer_or_nil              # (-F)
      config :last_scan, nil, &c.integer_or_nil               # (-L)
      config :lower_MW, nil, &c.num_or_nil                    # (-B)
      config :upper_MW, nil, &c.num_or_nil                    # (-T)
      config :precursor_mass_tol, 1.4, &c.num                 # (-M)
      config :num_allowed_intermediate_scans_for_grouping, 1, &c.integer # (-S)
      config :charge_state, nil, &c.integer_or_nil            # (-C)
      config :num_required_group_scans, 1, &c.integer_or_nil  # (-G)
      config :num_ions_required, 0, &c.integer_or_nil         # (-I)
      config :output_path, nil                                # (-D)
      config :intensity_threshold, nil, &c.integer_or_nil     # (-E)
      config :use_unified_search_file, nil, &c.flag           # (-U)
      config :subsequence, nil                                # (-Y)
      config :write_zta_files, nil, &c.flag                   # (-Z)
      config :perform_charge_calculations, nil, &c.flag       # (-K)
      config :template_file, nil                              # (-O)
      config :options_string, nil                             # (-A)
      config :minimum_signal_to_noise, 3, &c.num              # (-R)
      config :minimum_number_of_peaks, 5, &c.integer          # (-r)
      
      config_attr(:extract_msn_help, nil, :arg_type => :flag) do |value|  # Print the extract_msn help         
        if value
          sh(extract_msn)
          exit
        end
      end
      
      CONFIG_MAP = [
        [:first_scan, 'F'],
        [:last_scan, 'L'],
        [:lower_MW, 'B'],
        [:upper_MW, 'T'],
        [:precursor_mass_tol, 'M'],
        [:num_allowed_intermediate_scans_for_grouping, 'S'],
        [:charge_state, 'C'],
        [:num_required_group_scans, 'G'],
        [:num_ions_required, 'I'],
        [:output_path, 'D'],
        [:intensity_threshold, 'E'],
        [:use_unified_search_file, 'U'],
        [:subsequence, 'Y'],
        [:write_zta_files, 'Z'],
        [:perform_charge_calculations, 'K'],
        [:template_file, 'O'],
        [:options_string, 'A'],
        [:minimum_signal_to_noise, 'R'],
        [:minimum_number_of_peaks, 'r']
      ]
      
      # Expands the input path and converts all forward slashes (/) 
      # to backslashes (\) to make it into a Windows-style path.
      def normalize(path)
        File.expand_path(path).gsub(/\//, "\\")
      end
      
      # Formats command options for extract_msn.exe using the current configuration.
      # Configurations are mapped to their single-letter keys using CONFIG_MAP.
      #
      # A default output_dir can be specified for when config[:output_path] is not 
      # specified.
      def cmd_options(output_dir=nil)
        options = CONFIG_MAP.collect do |key, flag|
          value = config[key]
          value = output_dir if flag == "D" && value == nil
          
          next unless value
          
          # formatting consists of stringifying the value argument, or
          # in escaping the value if the arguement is a path
          formatted_value = case key
          when :use_unified_search_file, :perform_charge_calculations, :write_zta_files
            "" # no argument
          when :output_path, :template_file 
            # path argument, escape
            "\"#{normalize value}\""  
          else 
            # number or string, simply stringify
            value.to_s
          end

          "-#{flag}#{formatted_value}"
        end
        
        options.compact.join(" ")
      end
      
      # Formats the extract_msn.exe command using the specified input_file,
      # and the current configuration.  A default output directory can be 
      # specified using output_dir; it will not override a configured output
      # directory.
      #
      # Note that output_dir should be an EXISTING filepath or relative 
      # filepath.   execute_msn.exe will not generate .dta files if the  
      # output_dir doesn't exist.
      def cmd(input_file, output_dir=nil)
        args = []
        args << "\"#{normalize extract_msn}\""
        args << cmd_options(output_dir)
        args << "\"#{normalize input_file}\""
        
        args.join(' ')
      end
      
      # Used to infer the default output directory (which is the RAW filepath 
      # minus the extension).  To set a custom default output directory, set the
      # inference block using:
      #
      #   task.inference {|input_file|  ... return default output dir ... }
      #
      # The output_path configuration overrides this default output directory
      # in all cases.
      def filepath(input_file) 
        inference_block ? inference_block.call(input_file) : input_file.chomp('.RAW')
      end
      
      def process(input_file)
        extname = File.extname(input_file)
        raise "Expected .RAW file: #{input_file}" unless  extname =~ /\.RAW$/i
        
        # Target the output to a directory with the same basename as the raw 
        # file, minus the extension, unless an output_path is already specified
        output_dir = (output_path == nil ? filepath(input_file) : output_path)
        mkdir(output_dir)
        command = cmd(input_file, output_dir)
        
        log :sh, command
        if app.options.verbose
          sh(command)
          puts ""  # add extra line to make logging nice
        else
          capture_sh(command, true)
        end
        
        # This may select additional .dta files that existed before raw_to_dta
        # TODO - maybe read lcq_dta for files? 
        Dir.glob( File.expand_path(File.join(output_dir, "*.dta")) ) 
      end
      
    end
  end
end