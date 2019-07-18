def check_pods
  system("sh check_pods_manifest_lock.sh || cd Example && bundle exec pod install")
end

def check_bundle
  system("bundle check || bundle install")
end

def check_ios_sim
  system("which npm || brew install npm")
  system("which ios-sim || npm install ios-sim -g")
end

def check_dependencies
  check_bundle
  check_pods
  check_ios_sim
end

def system_or_exit(cmd, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout
  system(cmd) or raise "******** Build failed ********"
end

def plistbuddy_get(key)
  `/usr/libexec/PlistBuddy -c "Print #{key}" Authenticator/Supporting\\\ Files/application.plist`.strip
end

def is_ci?
  ENV['CI'] != nil
end
