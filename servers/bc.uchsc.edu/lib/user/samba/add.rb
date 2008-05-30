module User
  # == Description
  # Adds the specified user to the samba server.
  #
  # created by: Simon Chiang
  # date:  2006-06-12  original .sh script
  # date:  2006-06-12  annotation and testing
  # date:  2008-05-30  ported to tap
  # run as: root
  #
  # This administrative script adds a standard share to 
  # a samba configuration file.  The samba configuration 
  # file is usually located at: /etc/samba/smb.conf
  #
  # The standard share is:
  # [username]
  #   comment = user home
  #   path = /home/username
  #   valid users = username
  #   public = no
  #   browseable = no
  #   writable = yes
  #   create mask = 0660
  #   directory mask = 0770
  #
  # This share works with the bc.uchsc.edu server structure
  # where research groups are allowed access to ALL group
  # data.  Hence the users must have appropriate masks so 
  # that files they create can be read by other members of 
  # the group.
  module Samba
    class Add < Tap::Task

      config :smbpasswd_file, '/etc/samba/smbpasswd'
      config :smb_config_file, '/etc/samba/smb.conf'
      config :share_template, %Q{
[<%= username %>]
  comment = user home
  path = /home/<%= username %>
  valid users = <%= username %>
  public = no
  browseable = no
  writable = yes
  create mask = 0660
  directory mask = 0770
}

      def check_addable(username)
        # check that the user is not in the smbpasswd file
        if File.read(smbpasswd_file) =~ Regexp.new(username)
          raise ArgumentError.new("#{username} is already in the smbpasswd file: #{smbpasswd_file}")
        end

        # check that a share by the name [$1] does not exist
        if File.read(smb_config_file) =~ Regexp.new("[#{username}]")
          raise ArgumentError.new("A share [#{username}] is already in the config file: #{smb_config_file}")
        end
      end

      def process(username)
        # Check that the user can be added
        log "Checking if user '#{username}' can be added to the samba server..."
        check_addable(username)

        # Add the user to the samba server
        log "Attempting to add the user..."
        
        prepare(smb_config_file)
        File.open(smb_config_file, "a") do |file|
          file.puts # template
        end

        # add the user to the smbpasswd file
        puts "Please enter a samba password for the user."
        sh Q%{smbpasswd -a #{username}} do |error|
          raise "The user could not be added to the samba server."
        end

        # restart the samba server
        log "Restarting the samba server."
        sh %Q{/etc/init.d/smb restart}
        
        nil
      end
    end
  end
end