#!/usr/bin/env jruby
require 'rubygems'
require 'jmx4r'

class_loading = JMX::MBean.find_by_name "java.lang:type=ClassLoading"

# implicit way...
class_loading.attributes.keys.each { |attr| puts "#{attr}: #{class_loading.send attr}"}

puts "--"

# ... or explicit
puts "loaded class count: #{class_loading.loaded_class_count}"
puts "total loaded class count: #{class_loading.total_loaded_class_count}"
puts "unloaded class count: #{class_loading.unloaded_class_count}"
puts "verbose: #{class_loading.verbose}"
