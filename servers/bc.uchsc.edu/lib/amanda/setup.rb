module Amanda
  # == Description
  # Setup a basic AMANDA backup of localhost by the specified
  # name. 
  #
  # === Usage
  # tap run amanda/setup BACKUP_NAME
  #
  class Setup < Tap::FileTask

    config :config_dir, '/etc/amanda'
    config :holdingdisk, '/dumps/amanda'
    
    config :org, ""
    config :email, ""
    config :n_tapes, 33
    config :disk_size, 499000  # in MB
    
    config :user, 'amandabackup'
    config :group, 'disk'

    config :libexecdir, '/usr/lib/amanda'

    config :xinetd, true
    config :dumpdates, '/var/amanda/amandates'
    
    def hostname
      capture_sh('hostname').chomp("\n")
    end

    def path(*paths)
      filepath(config_dir, *paths)
    end

    def template(src, target, binding)
      log :template, target
      
      prepare target
      File.open(target, 'w') do |output|
        output << ERB.new( File.read(src) ).result(binding)
      end
    end
    
    def process(name, space)

      unless File.exists?(config_dir) && File.directory?(config_dir)
        raise "directory doesn't exist: #{config_dir}" 
      end

      logdir = File.join(config_dir, name)
      infofile = File.join(config_dir, name, 'curinfo')
      indexdir = File.join(config_dir, name, 'index')
      tapelist = File.join(config_dir, name, 'tapelist')

      config = File.join(config_dir, name, 'amanda.conf')
      disklist = File.join(config_dir, name, 'disklist')

      [logdir, infofile, indexdir, holdingdisk].each do |dir|
        log :mkdir, dir
        
        prepare dir
        sh "mkdir -p #{dir}"
        sh "chown #{user}:#{group} #{dir}"
      end

      [tapelist, dumpdates].each do |target|
        log :touch, target
        
        prepare target
        sh "touch #{target}"
        sh "chown #{user}:#{group} #{target}"
      end
      sh "chmod 664 #{dumpdates}"

      [config, disklist].each do |target|
        src = app.filepath(:templates, 'amanda', File.basename(target))
        template(src, target, binding)

        sh "chown #{user}:#{group} #{target}"
      end

      ['/etc/xinetd.d/amanda'].each do |target|
        src = app.filepath(:templates, target)
        template(src, target, binding)

        sh "/etc/init.d/xinetd restart"
      end if xinetd
    
      # still to add... crontab
      # 0 16 * * 1-5 /usr/local/sbin/amcheck -m confname
      # 45 0 * * 2-6 /usr/local/sbin/amdump confname

      template(app.filepath(:templates, 'amanda', 'amandahosts'), File.expand_path("~#{user}/.amandahosts"), binding)

      sh "chown #{user} ~#{user} ~#{user}/.amandahosts"
      sh "chmod 755 ~#{user}"
      sh "chmod 600 ~#{user}/.amandahosts"

      nil
    end

  end
end
