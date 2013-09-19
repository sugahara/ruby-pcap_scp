# -*- coding: utf-8 -*-
## 
## Pcap file transmitter using scp in Ruby
## usage: ruby ruby-dumpscp.rb [local_dir] [remote_dir] [host] [username] [ssh_key_path] [pass phrase]
##
## WARNING : LOCAL FILES ARE DELETED AFTER THE COMPLETION OF TRANSMITTING. 
##
##Copyright (C) 2012 Jun SUGAHARA All Rights Reserved.
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


# 最後の/を取り除く
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

files.delete_if {|name| File.extname(name) != ".pcap"}

files.each do |name|
  Net::SCP.start(host, id, options) do |scp|
    puts "#{Time.now} uploading file... #{local_dir}/#{name}"
    scp.upload!("#{local_dir}/#{name}",remote_dir)
    puts "#{Time.now} uploaded. #{local_dir}/#{name}"
  end
  puts "#{Time.now} detele file #{local_dir}/#{name}"
  FileUtils.rm("#{local_dir}/#{name}")
end
