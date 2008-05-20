module Amanda
  # == Description
  # Replace with a description for SetupDrive
  # === Usage
  # Replace with usage instructions
  #
  class SetupDrive < Tap::FileTask
    
    config :space, "/dumps"   # TODO -- check not nil, and does not exist.  the space folder for the dumps
    config :n_slots, 5        # TODO -- check > 1
    config :user, 'amandabackup'
    config :group, 'disk'

    def process(name)
      sh "mkdir -p #{space}/vtapes"
      sh "chown #{user}:#{group} #{space}/vtapes"
      sh "chmod 750 #{space}/vtapes"

      sh "sudo -u #{user} mkdir -p #{space}/vtapes/#{name}/slots"

      FileUtils.cd "#{space}/vtapes/#{name}/slots"
      1.upto(n_slots) do |slot|
        sh "sudo -u #{user} mkdir slot#{slot}"
      end

      sh "sudo -u #{user} ln -s slot1 data"

      1.upto(n_slots) do |slot|
        sh "sudo -u #{user} amlabel #{name} #{name}-#{slot} slot #{slot}"
      end
    end
    
  end
end
