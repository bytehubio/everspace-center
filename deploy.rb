#!/usr/bin/env ruby

name = "everspace.center"
system("eval \"$(ssh-agent -s)\" || true && ssh-add ~/.ssh/#{name} || true && git reset --hard HEAD || true && git pull origin master")
 system("swift package resolve")
#system("swift package update")
 system("swift build -c release -Xswiftc -Ounchecked -Xswiftc -whole-module-optimization -Xcc -O2")
#system("swift build -c debug")
system("pkill -9 -f #{name}")
# system("/home/devton/swift/#{name}/.build/release/#{name} --env production > /home/devton/swift/#{name}/log.txt 2>&1 &")
system("sudo supervisorctl restart #{name}-app")
