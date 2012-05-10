require 'net/ssh'
require 'net/scp'

local_dir = ARGV[0]
remote_dir = ARGV[1]
host = ARGV[2]
id = ARGV[3]
key = ARGV[4]
pass = ARGV[5]
options = {
  :keys => key,
  :passphrase => pass
}
files = Dir::entries(local_dir)



files.each do |name|
  if File.extname(name) == ".pcap"
    new_dir_name = name.split("_")[2][0...8]
      if new_dir_name == Time.now.strftime("%Y%m%d")
        #DO NOTHING(A FILE IN USE)
      else
        Dir::mkdir("#{local_dir}/#{new_dir_name}", 0776) unless FileTest.exist?("#{local_dir}/#{new_dir_name}")
        File.rename("#{local_dir}/#{name}", "#{local_dir}/#{new_dir_name}/#{name}")
      end
  end
end

files = Dir::entries(local_dir)
files.each do |name|
  if FileTest::directory?(name) && name != ".." && name != "."
    dump_file = Dir::entries("#{local_dir}/#{name}")
    dump_file.each do |d|
      Net::SCP.start(host, id, options) do |scp|
        scp.upload!("#{local_dir}/#{name}/#{d}",remote_dir)
      end
    end
  end
end
