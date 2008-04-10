#!/usr/bin/env jruby
require 'rubygems'
require 'jmx4r'

logging = JMX::MBean.find_by_name "java.util.logging:type=Logging"
puts "--"
logging.logger_names.sort.each do |logger|
  level = logging.get_logger_level logger
  puts "#{logger} #{level}"
end
puts "--"

if ARGV.length == 1
  level = ARGV[0]
  puts "set all loggers to #{level}"
  logging.logger_names.each do |logger|
    logging.set_logger_level logger, level
  end    
end

if ARGV.length == 2
  logger = ARGV[0]
  level = ARGV[1]
  puts "set #{logger} to #{level}"
  logging.set_logger_level logger, level
end
