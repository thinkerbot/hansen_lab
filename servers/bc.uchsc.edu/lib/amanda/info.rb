module Amanda
  # == Description
  # Prints a the configuration information, as documented in the
  # {Quick Start}[http://wiki.zmanda.com/index.php/Quick_start]
  #
  # Services should have entries like:
  # * amanda 10080/udp
  # * amandaidx 10082/tcp
  # * amidxtape 10083/tcp 
  #
  #-- TODO
  # The defaults for the amanda/setup task should be constructed 
  # as the output of info.
  # * looks like we use xinetd (Fedora -- check for this?)
  #
  # === Usage
  # tap run amanda/info
  #
  class Info < Tap::FileTask

    config :fields, %w{CLIENT_LOGIN CONFIG_DIR AMANDA_DBGDIR libexecdir listed_incr_dir}

    def process
      lines = capture_sh("/usr/sbin/amadmin xx version").split(/\n/)
      info = {}

      puts
      puts "amadmin:"
      lines.each do |line|
        fields.each do |field|
          next if line.index(field) == nil
          puts line.strip
          info[field] = line
        end
      end

      puts
      puts "/etc/services:"
      info['services'] = File.read('/etc/services').split(/\n/).select do |line|
        next(false) if line.index('amanda') == nil
        puts line
        true
      end

      info
    end

  end
end
