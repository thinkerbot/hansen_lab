module User
  module Samba
  # == Description
# Removes the specified user from the samba server.
#
# created by: Simon Chiang
# date:  2006-06-12  original .sh script
# date:  2006-06-12  annotation and testing
# date:  2008-05-30  ported to tap
# run as: root
#
# This administrative script removes a standard share 
# from a samba configuration file.  The samba config
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
    class Remove < Tap::Task

    
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

      def process(username)
log "Attempting to remove '#{username}' from the samba server..."

# try removing the standard share from the config file.
contents = File.read(smb_config_file)
unless contents =~ Regexp.new(share)
  raise "The user could not be removed from samba server.  Missing share:\n#{share}"
end

prepare(smb_config_file)
File.open(smb_config_file, "w") do |file|
  file << contents.gsub(share, "")
end

  log "Removing the user from the password file..."
  # only remove the user from the smbpasswd file if
  # the config file script was successful
  sh %Q{smbpasswd -x #{username}}

# restart the samba server
log "Restarting the samba server."
sh Q%{/etc/init.d/smb restart}

      end
      
    end
  end
end