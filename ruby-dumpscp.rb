# -*- coding: utf-8 -*-
## 
## Pcap file transmitter using scp in Ruby
## usage: ruby ruby-dumpscp.rb [local_dir] [remote_dir] [host] [username] [ssh_key_path] [pass phrase]
## 
## Copyright (C) 2008 Jun SUGAHARA All Rights Reserved.
##

require 'net/ssh'
require 'net/scp'
require 'fileutils'

#現在のpcapファイルの数をかぞえるメソッド
def pcap_file_count(files)
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

#ダンプ中のファイルのみしかない場合は転送処理を行わない
if pcap_file_count(files) > 1
  latest_time = Time.utc(1970)
  files.each do |name|
    # pcapファイルのみ処理する
    #最新の（おそらくダンプ中の）pcapファイル名を取得
    if File.extname(name) == ".pcap"
     if latest_time < File.atime("#{local_dir}/#{name}")
       latest_time = File.atime("#{local_dir}/#{name}")
       @latest_file = name
     end
    end
  end
  #ダンプ中のファイルを残して新しいディレクトリに移動
  files.each do |name|
    if File.extname(name) == ".pcap"
      if name != @latest_file
        new_dir_name = name.split("_")[2][0...8]
        Dir::mkdir("#{local_dir}/#{new_dir_name}", 0777) unless FileTest.exist?("#{local_dir}/#{new_dir_name}")
        FileUtils.chmod(0777,"#{local_dir}/#{new_dir_name}")
        File.rename("#{local_dir}/#{name}", "#{local_dir}/#{new_dir_name}/#{name}")
      end
    end
  end
end

files = Dir::entries(local_dir)
files.each do |name|
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
