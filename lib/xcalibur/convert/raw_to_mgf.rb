require 'xcalibur/convert/raw_to_dta'
require 'xcalibur/convert/dta_to_mgf'

module Xcalibur
  module Convert
    # :startdoc::manifest convert RAW files to mgf format
    # Extracts spectra from a .RAW file and formats them as mgf (Mascot
    # Generic Format).  RawToMgf is a workflow that uses the RawToDta
    # and DtaToMgf tasks, and can be configured through these tasks
    # using the following configuration files:
    #
    #   config/xcalibur/convert
    #   |- raw_to_mgf.yml               # configures RawToMgf
    #   `- raw_to_mgf
    #    |- raw_to_dta.yml              # configures RawToDta
    #    `- dta_to_mgf.yml              # configures DtaToMgf
    #
    # Mgf files are named after the RAW file they represent; the group
    # merge file is named 'merge.mgf' although an alternate merge file
    # name can be specified in the options.
    #
    class RawToMgf < Tap::Workflow
      
      config :output_dir, :data                  # specifies the output directory
      config :merge_file, 'merge.mgf'            # the group merge file
      config :merge_individual, true, &c.switch  # merge the dta's for each RAW file
      config :merge_group, true, &c.switch       # merge the dta's for all RAW files
      config :remove_dta_files, true, &c.switch  # clean up dta files upon completion
      
      def workflow 
        # Define the workflow entry and exit points,
        # as well as the workflow logic.
        dta_dirs = []
        raw_to_dta = Xcalibur::Convert::RawToDta.new(name('raw_to_dta'))
        raw_to_dta.inference do |input_file|
          dir = app.filepath(output_dir, File.basename(input_file).chomp(".RAW"))  
          dta_dirs << dir
          dir
        end
  
        dta_to_mgf = Xcalibur::Convert::DtaToMgf.new(name('dta_to_mgf'))

        n_inputs = nil
        self.entry_point = Tap::Task.new do |task, *input_files|
          n_inputs = input_files.length
          input_files.each do |input_file|
            raw_to_dta.enq(input_file)
          end
        end
        
        group_results = []
        raw_to_dta.on_complete do |_result|
          if merge_individual
            output_file = app.filepath(output_dir,  File.basename(_result._original).chomp(".RAW") + ".mgf")
            dta_to_mgf.enq(output_file, *_result._expand)
          end
          
          # collect _results to determine when all the input
          # files have been processed by raw_to_dta
          group_results << _result
          
          # When all the input files have been converted, merge the
          # group and enque a task to cleanup the dta files, as specified.
          if group_results.length == n_inputs
            if merge_group
              output_file = app.filepath(output_dir, merge_file)
              all_results = group_results.collect {|_result| _result._expand }.flatten
              dta_to_mgf.enq(output_file, *all_results)
            end
            
            if remove_dta_files
              cleanup = Tap::Task.new do |task, raw_dir|           
                task.log :rm_r, raw_dir
                FileUtils.rm_r  raw_dir
              end
              dta_dirs.each {|dir| cleanup.enq(dir)}
            end
          end
        end

        self.exit_point = dta_to_mgf
      end
    end
  end
end