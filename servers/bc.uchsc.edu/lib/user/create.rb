module User

# == Description
# Creates a new group user.
#
# created by: Simon Chiang
# date:  2006-04-21  original .sh script
# date:  2008-05-30  ported to tap
# run as: root
#
# This administrative script creates a standard user
# on the server.  Users are created with the following:
#   -the full name	  (John Doe)	  {fullname}
#   -the user name	  (doej)		    {username}
#   -the group    	  (msf) 		    {group}
#   -the group admin	(msf_admin)	  {group_admin} 
#
# The script prompts for all passwords as it runs; it
# is not possible to enter passwords into the command
# line.
#
# Users are created to be able to access the server 
# via Samba. Samba is the program that allows Windows 
# to access drives on Linux.  
#
# The new user will belong to group, and be given the 
# standard Samba share setup with the script
# modifySambaConfig.pl
#
# The new user will be given a home data folder accessible
# only by them and the group administrator.
#
#   /home/user               user, group_admin         rwxrwx---   (mod/access for user and group admin only)
#   |- group           link
#   `- mirror/archive  link
#
  class Create < Tap::Task
    include Tap::Support::ShellUtils
    
    config :home_dir, "/home"
    
    def process(fullname, username, group, group_admin)

home = app.filepath(home_dir, username)

#
# Add the user
#

log "Adding the user #{username}..."
sh %Q{useradd -m -s /bin/bash -g #{group} -c "#{fullname}" #{username}}
sh %Q{usermod -G users,#{group} #{username}}

#modify the home directory of the added user
sh %Q{chmod 750 #{home}}
sh %Q{chown #{username} #{home}}
sh %Q{chgrp #{group_admin} #{home}}

puts "Please enter a password for '#{username}'."
sh %Q{passwd #{username}}

    end
    
  end
end