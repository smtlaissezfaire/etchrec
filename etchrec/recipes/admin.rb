Capistrano.configuration(:must_exist).load do
  
  task :disable_root_login do
    sudo "sed -r \"s/PermitRootLogin.*/PermitRootLogin no/\" -i /etc/ssh/sshd_config"
    reload_ssh
  end
  
  task :enable_root_login do
    sudo "sed -r \"s/PermitRootLogin.*/PermitRootLogin yes/\" -i /etc/ssh/sshd_config"
    reload_ssh
  end                                                                      
  
  task :reload_ssh do
    sudo "/etc/init.d/ssh reload"
  end
  
  # set desired ssh port
  task :set_ssh_port do 
    raise RuntimeError, "Must have ssh_options[:port] set to old port value" unless ssh_options[:port]
    
    STDOUT.printf "New Port?: "
    new_port = STDIN.gets.chomp
    old_port = ssh_options[:port]
          
        
    sudo "sed -r \"s/(Port)\s(#{old_port})/\\1 #{new_port}/\" -i /etc/ssh/sshd_config"
    reload_ssh
    STDOUT.puts "Make sure to change your capistrano configuration to reflect the change of ssh to port #{new_port}" 
  end
  
  task :enable_security do
    set_ssh_port
    disable_root_login
  end
  
end