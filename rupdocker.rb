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
      options._container << v
    end
  end
  
  opts.on("-r", "--require LIBRARY",
    "Require the LIBRARY before executing your script") do |lib|
    options.library << lib
  end
end.parse!()

# Needed variables
# git_rep = "https://github.com/TcM1911/RUpdocker.git"
git_path =  `whereis git | cut -d " " -f 2`

_container = options._container

# # Generate a random name for download dir
download_dir = SecureRandom.hex(4)

# Download the docker update scripts.
# git_download = system(git_path, "clone", git_rep, "/tmp/#{download_dir}")

def get_running_containers()
  #ps_output = exec("sudo docker ps")
  ps_output = 'CONTAINER ID        IMAGE                    COMMAND             CREATED             STATUS              PORTS                                      NAMES
b52a163e70cd        image/mailrelay:latest   "./start_relay"     7 days ago          Up 39 hours         0.0.0.0:110->110/tcp                       mailrelay
b8d57ae3cade        openvpn:latest           "./start_vpn"       7 days ago          Up 39 hours         0.0.0.0:21->21/tcp, 0.0.0.0:587->587/tcp   gatekeeper_uk'
end

# Extracting the image name from the docker ps output.
def find_image(docker_ps_output, container)
  output_ar = docker_ps_output.split(/\n/)
  output_ar.each do |line|
    temp_string = line.to_s
    if temp_string.match(container)
      return temp_string.split(/\s+/)[1]
    end
  end
end

docker_ps = get_running_containers
image = find_image docker_ps, _container