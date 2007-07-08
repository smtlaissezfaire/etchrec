require 'capistrano'


class Capistrano::Actor

  def sudo_put(local_file=nil, server_file="", h={})
    raise RuntimeError, "Must give local file" if local_file.nil?
    raise RuntimeError, "Must give server file a path" if server_file.nil? || server_file.empty?
    
    server_file_basename = File.basename(server_file)
                                   
    use_temp do |tmp|
      put local_file, "#{tmp}/#{server_file_basename}", h
      sudo "cp #{tmp}/#{server_file_basename} #{server_file}"     
    end                               
  end                                 


private

  def use_temp(&blk)
    raise RuntimeError, "must have deploy_to variable set" unless deploy_to
    tmp = "/tmp/cap"
        
    run "test -d #{tmp} || mkdir #{tmp}"    
    blk.call(tmp)    
    run "rm -rf #{tmp}"
  end                                                     
  
  

end