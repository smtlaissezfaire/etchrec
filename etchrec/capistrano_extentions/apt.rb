module Apt
  def install_stable(*args)
    install({:base => args}, :stable)
  end
  
  def update
    sudo "apt-get update"
  end             
  
  def upgrade
    sudo "apt-get upgrade"
  end
    
  
  # call like this:
  #
  #   apt.package :apache do |apache|
  #     apache.enable_module :dav_svn
  #     apache.restart
  #   end             
  #
  # or like this:
  #   apt.package(:apache).enable_module :dav_svn
  #   apt.package(:apache).restart
  #
  def package(name, &blk)
    
    name = name.to_s
    module_name = "apt_#{name}"
    capitalized_name = "Apt::#{name.capitalize}"
    Capistrano.plugin(module_name, instance_eval(capitalized_name))
    
    if block_given?
      blk.call(instance_eval(module_name))
    else            
      instance_eval(module_name)
    end
  end
  

  module Apache
    
    def method_missing(sym, *args)
      if sym.to_s =~ /^(start|stop|restart|reload)$/
        sudo "#{apache_ctl} -k #{$1}"
      else
        super
      end 
    end
    
    def enable_module(name)
      sudo "a2enmod #{name.to_s}"
    end                   

    def disenable_module(name)
      sudo "a2dismod #{name.to_s}"
    end                    

    def enable_site(name)
      sudo "a2ensite #{name.to_s}"
    end                    

    def disenable_site(name)
      sudo "a2dissite #{name.to_s}"
    end

    def ssl_enabled?
      apache_ssl_enabled ? true : false
    end  
              
  end
end 

  

Capistrano.plugin :apt, Apt  
#Capistrano.plugin "apt.apache", Apt::Apache         
