module Amanda
  # == Description
  # Replace with a description for SetupDrive
  # === Usage
  # Replace with usage instructions
  #
  class SetupDrive < Tap::FileTask
    
    config :n_tapes, 33       
    config :user, 'amandabackup'
    config :group, 'disk'

    def process(name, space)
      
      raise "already exists: #{space}/vtapes/#{name}" if File.exists?("#{space}/vtapes/#{name}")
      
      sh "mkdir -p #{space}/vtapes/#{name}"
      sh "chown #{user}:#{group} #{space}/vtapes/#{name}"
      sh "chmod 750 #{space}/vtapes/#{name}"

      sh "sudo -u #{user} mkdir -p #{space}/vtapes/#{name}/slots"

      FileUtils.cd "#{space}/vtapes/#{name}/slots"
      1.upto(n_tapes) do |slot|
        sh "sudo -u #{user} mkdir slot#{slot}"
      end

      sh "sudo -u #{user} ln -s slot1 data"

      1.upto(n_tapes) do |slot|
        sh "sudo -u #{user} amlabel #{name} #{name}-#{slot < 10 ? '0' : ''}#{slot} slot #{slot}"
      end
      
      sh "sudo -u #{user} amtape #{name} reset"
      sh "sudo -u #{user} amcheck #{name}"
    end
    
  end
end
