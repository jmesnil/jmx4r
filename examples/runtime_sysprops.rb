#!/usr/bin/env jruby
require 'rubygems'
require 'jmx4r'

# This example shows how to iterate on TabularData

runtime = JMX::MBean.find_by_name "java.lang:type=Runtime"

# The system_properties attribute of the Runtime MBean is an instance of
#   TabularDataSupport
sysprops = runtime.system_properties
sysprops.each do | sysprop|
  puts "#{sysprop["key"]} = #{sysprop["value"]}"
end
