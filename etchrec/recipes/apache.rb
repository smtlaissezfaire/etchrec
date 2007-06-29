Capistrano.configuration(:must_exist).load do
  
  set :apache_config_dir, "/etc/apache2"
  set :apache_ctl, "/usr/sbin/apache2"
  set :apache_ssl_enabled, false 

  task :enable_subversion do
    apt.package :apache do |apache|
      apache.enable_module :dav_svn
    end
  end                     

  task :enable_ssl do
    apt.package :apache do |apache|
      apache.enable_module :ssl
    end
  
    # read ports.conf - add Listen 443 if not there 
    ports_conf = "/etc/apache2/ports.conf"
  
    run "cat #{ports_conf}" do |channel, stream, data|
      unless data =~ /Listen 443/
        sudo "sh -c \"echo 'Listen 443' >> #{ports_conf}\"" 
      end
    end
  end 
                       
  desc "Configure Apache.  Overrides deprec"
  task :configure_apache, :roles => :web do

    set_apache_conf
  
    server_aliases = []
    server_aliases << "www.#{apache_server_name}"
    server_aliases.concat apache_server_aliases
    set :apache_server_aliases_array, server_aliases
   
    templates = File.dirname(__FILE__) + "/templates"
    
    if apache_ssl_enabled
      set :apache_ssl_ip, "*" unless apache_ssl_ip    
      file = "#{templates}/httpd-ssl.conf"
    else
      file = "#{templates}/httpd.conf"
    end
    
    unless apache_server_name
      set :apache_server_name, domain
    end                                                                 

    File.open(file) do |file|
      buffer = insert_custom_directives(file.read)
      buffer = render :template => buffer
      sudo_put buffer, apache_conf      
    end
  
    apt.package(:apache).enable_site(application)
  end
  
  desc "Overrides deprec's task - this time doing nothing"
  task :setup_apache, :roles => :web do
    # NOTHING...
  end

  desc "Start Apache "
  task :start_apache, :roles => :web do
    apt.package(:apache).start
  end

  desc "Restart Apache "
  task :restart_apache, :roles => :web do
    apt.package(:apache).restart
  end

  desc "Stop Apache "
  task :stop_apache, :roles => :web do
    apt.package(:apache).stop
  end

  desc "Reload Apache "
  task :reload_apache, :roles => :web do
    apt.package(:apache).reload
  end

  task :install_apache do
    apt.install_stable "apache2", "ssl-cert", "libssl-dev"
  end

  def insert_custom_directives(buffer)
    if buffer =~ /\<\/VirualHost\>/
      buffer = $`   #pre-match
      buffer += <<-HERE
        # Custom Directives
        <% if apache_custom_directives %>
          <% apache_custom_directives.each do |directive| %>
        <%= directive %>
          <% end %>
        <% end %> 
    
      </VirtualHost>
    
      HERE
   end   
   buffer
  end

  def set_apache_conf
    if apache_config_dir && application
      set :apache_conf, "#{apache_config_dir}/sites-available/#{application}"
    else
      raise RuntimeError, "No application name given"
    end
  end

end
