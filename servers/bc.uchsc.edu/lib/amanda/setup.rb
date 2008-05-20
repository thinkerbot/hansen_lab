module Amanda
  # == Description
  # Setup AMANDA on bc.
  # === Usage
  # tap run amanda/setup nil
  #
  class Setup < Tap::FileTask

    config :amanda_dir, '/etc/amanda'
    config :holdingdisk, '/dumps/amanda'

    config :user, 'amandabackup'
    config :group, 'disk'

    config :libexecdir, '/usr/lib/amanda'
    config :space, "/dumps"

    def localhost
      'amandahost.yourdomain.com'
    end

    def path(*paths)
      filepath(amanda_dir, *paths)
    end

    def template_binding(name)
      binding
    end

    def process(name)

      unless File.exists?(amanda_dir) && File.directory?(amanda_dir)
        raise "amanda_dir directory doesn't exist" 
      end

      logdir = File.join(amanda_dir, name)
      infofile = File.join(amanda_dir, name, 'curinfo')
      indexdir = File.join(amanda_dir, name, 'index')
      tapelist = File.join(amanda_dir, name, 'tapelist')

      config = File.join(amanda_dir, name, 'amanda.conf')
      disklist = File.join(amanda_dir, name, 'disklist')

      [logdir, infofile, indexdir, holdingdisk].each do |dir|
        prepare dir
        sh "mkdir -p #{dir}"
        sh "chown #{user}:#{group} #{dir}"
      end

      [tapelist].each do |file|
        prepare file
        sh "touch #{file}"
        sh "chown #{user}:#{group} #{file}"
      end

      [config, disklist].each do |target|
        src = app.translate(target, amanda_dir, :files)
        template(src, target, binding)

        sh "chown #{user}:#{group} #{file}"
      end

      ['/etc/xinet.d/amanda'].each do |target|
        src = app.filepath(:files, target)
        template(src, target, binding)

        sh "kill -HUP xinetd_process_id"
      end if xinetd
    
      # still to add... crontab
      # 0 16 * * 1-5 /usr/local/sbin/amcheck -m confname
      # 45 0 * * 2-6 /usr/local/sbin/amdump confname

      template(app.filepath(:files, 'amanda/amandahosts'), "~#{user}/.amandahosts", binding)

      sh "chown amandabackup ~#{user} ~#{user}/.amandahosts"
      sh "chmod 755 ~#{user}"
      sh "chmod 600 ~#{user}/.amandahosts"

      # dumpdates?
    end

    def template(src, target, binding)
      prepare target
      File.open(target, 'w') do |output|
        output << ERB.new( File.read(src) ).result(binding)
      end
    end
  end
end
