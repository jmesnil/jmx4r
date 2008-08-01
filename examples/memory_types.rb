#!/usr/bin/env jruby
require 'rubygems'
require 'jmx4r'
require 'jconsole'

mem_pools = JMX::MBean.find_all_by_name "java.lang:type=MemoryPool,*"
mem_pools.each do |pool|
  puts pool.object_name["name"]
end