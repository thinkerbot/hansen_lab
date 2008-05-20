module Amanda
  # == Description
  # Replace with a description for SetupDrive
  # === Usage
  # Replace with usage instructions
  #
  class SetupDrive < Tap::FileTask
    
    config :target, "/dumps"  # TODO -- check not nil, and does not exist.  the target folder for the dumps
    config :n_slots, 5        # TODO -- check > 1

    def process
      sh "mkdir -p #{target}/vtapes"
      sh "chown amanda:disk #{target}/vtapes"
      sh "chmod 750 #{target}/vtapes"

      sh "sudo -u amanda mkdir -p #{target}/vtapes/daily/slots"

      FileUtils.cd "#{target}/vtapes/daily/slots"
      1.upto(n_slots) do |slot|
        sh "sudo -u amanda mkdir slot#{slot}"
      end

      sh "sudo -u amanda ln -s slot1 data"

      1.upto(n_slots) do |slot|
        sh "sudo -u amanda amlabel daily daily-#{slot} slot #{slot}"
      end
    end
    
  end
end
