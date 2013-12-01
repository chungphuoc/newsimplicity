# A script that copies the development log into a date-named file.
require 'date'
require 'fileutils'

puts "Rotating Logs";
puts Date::today();
puts Time::now();
puts "working on dir #{ARGV[0]}"

new_log_name = "development_#{Date::today}.log"
puts "existing log moved to: #{new_log_name}"
old_old_name = "development.log"

FileUtils::mv "#{ARGV[0]}/log/#{old_old_name}", "#{ARGV[0]}/log/#{new_log_name}"
puts "Done"