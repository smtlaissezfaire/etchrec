require File.dirname(__FILE__) + "/apache"
require File.dirname(__FILE__) + "/admin"

Capistrano.configuration(:must_exist).load do
    
  desc "install rails stack"
  task :install_rails_stack do
    setup_user_perms
    install_packages_for_rails # install packages that come with distribution
    install_rubygems
    install_gems 
    install_apache
    install_svn
    enable_subversion
    enable_ssl
    update_apt                  
  end
  
  task :install_rubygems do
    apt.install_stable "rubygems"
    add_gems_bin_to_load_path
  end                        
  
  task :add_gems_bin_to_load_path do
    profile = "/etc/profile"
    load_path = "/var/lib/gems/1.8/bin"

    run "cat #{profile}" do |channel, stream, data|
      unless data.include?(load_path)
        data.gsub! /PATH\=\"(.*)\"/, "PATH=\"\\1:#{load_path}\""
        sudo_put data, profile 
      end
    end
  end
  
  task :install_php do
    apt.install_stable "php5"
  end                       
  
  task :install_svn do
    apt.install_stable "subversion", "libapache2-svn", "subversion-tools"
  end
  
  task :install_ssh do
    apt.install_stable "ssh"
  end
  
  task :update_apt do
    apt.update
    apt.upgrade
  end

end
