describe "PermissionScheme" do  
  
  GROUP = "msf"
  GROUP_ADMIN_GROUP = "#{GROUP}_admin"
  GROUP_SHARE_GROUP = "group_share"
  
  DEFAULT_USER = GROUP
  GROUP_ADMIN = "#{GROUP}_admin"
  GROUP_SHARE = "group_share"

  GROUP_USER = "chiangs"
  NON_GROUP_USER = "dlms"

  def sh(cmd)
    puts "\n% #{cmd}"
    system(cmd)
  end

  it "should allow default user to list /data/#{GROUP}" do
    sh("sudo -u #{DEFAULT_USER} ls /data/#{GROUP}").should be_true
  end

  it "should allow group admin to list /data/#{GROUP}" do
    sh("sudo -u #{GROUP_ADMIN} ls /data/#{GROUP}").should be_true
  end

  it "should allow group user to list /data/#{GROUP}" do
    sh("sudo -u #{GROUP_USER} ls /data/#{GROUP}").should be_true
  end

  it "should prevent non group users to list /data/#{GROUP}" do
    sh("sudo -u #{NON_GROUP_USER} ls /data/#{GROUP}").should_not be_true
  end
end
