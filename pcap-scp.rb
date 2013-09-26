# -*- coding: utf-8 -*-
## 
## usage: ruby ruby-dumpscp.rb [local_dir] [remote_dir] [host] [username] [ssh_key_path] [pass phrase]
##
## Copyright (C) 2012 Jun SUGAHARA All Rights Reserved.
##

require 'net/ssh'
require 'net/scp'
require 'fileutils'


if ARGV[0][ARGV[0].size-1] == "/"
  local_dir = ARGV[0].chop # remove "/"
end

remote_dir = ARGV[1]
host = ARGV[2]
id = ARGV[3]
options = {
  :keys => ARGV[4],
  :passphrase => ARGV[5]
}
files = Dir::entries(local_dir)

files.delete_if {|name| File.extname(name) != ".pcap"} #.pcap file only

files.each do |name|
  Net::SCP.start(host, id, options) do |scp|
    puts "#{Time.now} uploading file... #{local_dir}/#{name}"
    scp.upload!("#{local_dir}/#{name}",remote_dir)
    puts "#{Time.now} uploaded. #{local_dir}/#{name}"
  end
  puts "#{Time.now} detele file #{local_dir}/#{name}"
  FileUtils.rm("#{local_dir}/#{name}")
end
