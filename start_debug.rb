#!/usr/bin/env ruby

current_file_path = File.expand_path(File.dirname(__FILE__))
ssh_key_name = "everspace.center"
system("swift package resolve")
#system("swift package update")
system("swift build -c debug")
system("cd #{current_file_path}/get_congig_params && npm install")
system("pkill -9 -f #{ssh_key_name}")
# system("sudo supervisorctl stop #{ssh_key_name}-app")
system("/home/devton/swift/#{name}/.build/debug/#{name} --env production")

