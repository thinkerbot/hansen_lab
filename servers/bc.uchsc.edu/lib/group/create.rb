module Group

  # == Description
  # This administrative script creates a standard group
  # on the server.
  #
  # created by: Simon Chiang
  # date:  2006-04-21  original .sh script
  # date:  2008-05-30  ported to tap
  # run as: root
  #
  # Groups should be able to access the server via Samba.  
  # Samba is the program that allows Windows to access 
  # drives on Linux. 
  #
  # Creating a group requires the following steps:
  # 1. Create groups:              group, group_admin
  # 2. Create users:               group, group_admin
  # 3. Add users to samba server:  group, group_admin
  # 4. Create group data folders:
  #
  #   /
  #   |- data
  #   |  `- group              group_admin, group        rwxr-x---   (access for all group users, mod for admin)
  #   |     |- archive         group_admin, group        rwxr-x---   (access for all group users, mod for admin)
  #   |     |  |- users        group_admin, group        rwxr-x---   (access for all group users, mod for admin)
  #   |     |  `- projects     group_admin, group        rwxr-x---   (access for all group users, mod for admin)
  #   |     |
  #   |     |- common          group_admin, group        rwxrwx---   (mod/access for all group users)
  #   |     |- management      group_admin, group        rwxrwx---   (mod/access for all group users)
  #   |     `- projects        group_admin, group        rwxrwx---   (mod/access for all group users)
  #   |
  #   `- home
  #      `- group_admin        group_admin, group_admin  rwxrwx---   (mod/access for group admin only)
  #         |- users           group_admin, group_admin  rwxrwx---
  #         |- group           link
  #         `- mirror/archive  link
  #
  # 5. Configure bashrc to set the correct masks for group  
  # users. This is accomplished by adding a line to bashrc 
  # that causes the group to be identified as a server-group 
  # (see the server setup scripts for more information).
  #
  class Create < Tap::Task
    include Tap::Support::ShellUtils

    config :data_dir, "/data"
    config :home_dir, "/home"

    def process(group)

      group_user = group
      group_admin = "#{group}_admin"
      admin_group = group_admin

      #
      # Add the groups
      #
      
      log "add group #{group}" 
      sh %Q{groupadd -f #{group}}
      log "add group #{group_admin}"
      sh %Q{groupadd -f #{group_admin}}

      #
      # Create the group administrator, putting $groupAdmin into $groupAdmin and $admin_group
      #

      #./createUser.sh "$groupName Administrator" $groupAdmin $group $groupAdmin
      #sh %Q{usermod -G #{group_admin},#{admin_group} #{group_admin}}
      #sh %Q{usermod -G #{group_admin},#{admin_group} #{group_admin}}

      nil
    end
  end
end