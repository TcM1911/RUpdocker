#!/usr/bin/env ruby
version=0.1

# Required libs.
require 'securerandom'
require 'optparse'
require 'ostruct'

# Read arg
options = OpenStruct.new
options._container = ""
options.library = []

OptionParser.new do |opts|
  opts.banner = "Usage: rupdocker [options]"
  
  opts.on('-h', '--help', "Prints this help") do
    puts opts
    exit
  end

  opts.on("-c", "--container DOCKERCONTAINER", "Container to update") do |v|
    if(v[/&/] || v[/;/])
      puts "Invalid container name!"
      exit
    else
      options._container = v
    end
  end
  
  # opts.on("-r", "--require LIBRARY",
  #   "Require the LIBRARY before executing your script") do |lib|
  #   options.library << lib
  # end

end.parse!()

# Needed variables
@git_rep = "https://github.com/TcM1911/RUpdocker.git"

_container = options._container

# # Generate a random name for download dir
@download_dir = SecureRandom.hex(6)
@container_name = ""

def download_resource_files
  puts "[-] Downloading scripts from the repo."
  # Download the docker update scripts.
  system "git clone #{@git_rep} /tmp/#{@download_dir}"
end
  
def get_running_containers
  ps_output = exec("sudo docker ps")
  # Test output
  #ps_output = 'CONTAINER ID        IMAGE                    COMMAND             CREATED             STATUS              PORTS                                      NAMES
  #b52a163e70cd        image/mailrelay:latest   "./start_relay"     7 days ago          Up 39 hours         0.0.0.0:110->110/tcp                       mailrelay
  #b8d57ae3cade        openvpn:latest           "./start_vpn"       7 days ago          Up 39 hours         0.0.0.0:21->21/tcp, 0.0.0.0:587->587/tcp   gatekeeper_uk'
end

# Extracting the image name from the docker ps output.
def get_image(docker_ps_output, container)
  output_ar = docker_ps_output.split(/\n/)
  output_ar.each do |line|
    temp_string = line.to_s
    if temp_string.match(container)
      return temp_string.split(/\s+/)[1]
    end
  end
end

def update_container
  # Generate random name for the temp container.
  @container_name = SecureRandom.hex(6)
  # Start the temp container and run the main update script.
  system "sudo docker run --name #{@container_name} -v /tmp/#{download_dir}/scripts:/tmp/docker-update/ #{image} /tmp/docker-update/main.sh"
  # Commit the updated container to the new image.
  system "sudo docker commit #{@container_name} #{image}"
  # Remove the temp container.
  system "sudo docker rm #{@container_name}"
  return true
end

def restart_container(container, image, start_arg, container_options)
  system "sudo docker stop #{container}"
  system "sudo docker run --name #{container} #{container_options} #{image} #{start_arg}"
end

def cleanup
  # Remove temp folder
  puts "[-] Cleaning up..."
  system "rm -rf /tmp/#{@download_dir}"
  puts "[-] Done!"
end


docker_ps = get_running_containers
image = get_image docker_ps, _container

if download_resource_files
  if update_container
    # Run as separate threads
    # restart_container
    cleanup
  else
    puts "Update failed!"
    exit 0
  end
else
  puts "Download failed!"
  exit 0
end
