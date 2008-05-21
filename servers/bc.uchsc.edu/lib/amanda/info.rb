module Amanda
  # == Description
  # Assembles (some) configuration information used by the Amanda::Setup task.  
  # The Info task must be run by a user with sufficient privileges for amadmin and
  # reading various files; ususally root is necessary.
  #
  # See the Amanda {Quick Start}[http://wiki.zmanda.com/index.php/Quick_start]
  # for more information.
  #
  # === Usage
  # tap run amanda/info
  #
  class Info < Tap::FileTask
    
    # A hash of configurations that are extracted from the output of:
    #
    #   % /usr/sbin/amadmin xx version
    #
    # The keys correspond to those used by Amanda::Setup
    MAP = {
      :user => 'CLIENT_LOGIN',
      :config_dir => 'CONFIG_DIR',
      :debug_dir => 'AMANDA_DBGDIR',
      :libexecdir => 'libexecdir',
      :listed_incr_dir => 'listed_incr_dir'}
    
    config :services, ['amanda 10080/udp', 'amandaidx 10082/tcp', 'amidxtape 10083/tcp'] # A list of the services expected by Amanda
    
    config :services_file, '/etc/services'    # The services file
    
    config :xinetd_file, '/etc/xinetd.conf'  # The xinetd config file
    
    # Returns true if all services are present in the services_file. 
    def check_services
      str = File.read(services_file)
      missing_services = services.select do |service|
        # the service entries often have multiple spaces...
        # ensure the regexp can handle variable spacing 
        str !~ Regexp.new(service.gsub(/\s/, '\s+'))
      end

      if missing_services.empty?
        true
      else
        log :warn, "missing amanda services in '/etc/services': [#{missing_services.join(', ')}]"
        false
      end
    end
    
    # Returns true if the xinetd_file exists
    def check_xinetd
      File.exists?(xinetd_file)
    end
    
    def process
      info = {}
      str = capture_sh("/usr/sbin/amadmin xx version")
      MAP.each_pair do |field, value|
        unless str =~ Regexp.new(%Q{#{value}="([^"]+)"})
          raise "\ncould not identify mapped field: #{field} (#{value})\n#{str}"
        end
    
        info[field] = $1
      end
      
      info[:services] = check_services
      info[:xinetd] = check_xinetd

      info
    end

  end
end
