# -*- coding: undecided -*-
require 'net/ssh'
require 'net/scp'
require 'fileutils'

#現在のpcapファイルの数をかぞえるメソッド
def pcap_file_cont(files)
  count = 0
  files.each do |name|
    if File.extname(name)==".pcap"
      count+=1
    end
  end
  count
end


if ARGV[0][ARGV[0].size-1] == "/"
  local_dir = ARGV[0].chop
end
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

if pcap_file_count(files) > 1
  latest_files = Dir::entries(local_dir)
  files.each do |name|
    if File.extname(name) == ".pcap"
      new_dir_name = name.split("_")[2][0...8]
      if new_dir_name == Time.now.strftime("%Y%m%d") || pcap_file_count(latest_files) <= 1
        #DO NOTHING(A FILE IN USE)
      else
        Dir::mkdir("#{local_dir}/#{new_dir_name}", 0776) unless FileTest.exist?("#{local_dir}/#{new_dir_name}")
        File.rename("#{local_dir}/#{name}", "#{local_dir}/#{new_dir_name}/#{name}")
        latest_files = Dir::entries(local_dir)
      end
    end
  end
end
puts "dir END"
files = Dir::entries(local_dir)
files.each do |name|
  p name
  if FileTest::directory?("#{local_dir}/#{name}") && name != ".." && name != "."
    dump_file = Dir::entries("#{local_dir}/#{name}")
    dump_file.each do |d|
      if File.extname(d) == ".pcap"
        p d
        Net::SCP.start(host, id, options) do |scp|
          p "#{local_dir}/#{name}/#{d}"
          scp.upload!("#{local_dir}/#{name}/#{d}",remote_dir)
        end
        FileUtils.rm("#{local_dir}/#{name}/#{d}")
      end
    end
    FileUtils.rmdir("#{local_dir}/#{name}")
  end
end
