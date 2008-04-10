#!/usr/bin/env jruby
require 'rubygems'
require 'jmx4r'

logging = JMX::MBean.find_by_name "java.util.logging:type=Logging"
logging.logger_names.each do |logger_name|
  logging.set_logger_level logger_name, "INFO"
end

memory = JMX::MBean.find_by_name "java.lang:type=Memory"
memory.verbose = true
memory.gc
