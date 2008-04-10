#!/usr/bin/env jruby
require 'rubygems'
require 'jmx4r'
require 'jconsole'

# This example will display memory usage for 3 Java applications running locally
# and manageable through diffent JMX ports.
# It will display memory usage, trigger a garbage collection on the 3 Java
# applications and display again the memory usage.

ports = [3000, 3001, 3002]

# We use jconsole as our target Java applications
# and specify on which port we can connect to their
# MBean server
ports.each { |port| JConsole::start :port => port }

# horizontal rule used for display
HR = "+----------------+----------------+----------------+"

def display_memory_usages (ports)
  puts HR
  puts "| Node           |      Heap Used |  Non Heap Used |"
  puts HR

  ports.each do |port|
    memory = JMX::MBean.find_by_name "java.lang:type=Memory", :port => port
    heap_used = memory.heap_memory_usage["used"]
    non_heap_used = memory.non_heap_memory_usage["used"]
    puts "| localhost:#{port} |#{heap_used.to_s.rjust(15)} |#{non_heap_used.to_s.rjust(15)} |"
  end

  puts HR
end

puts "Before GC:"
display_memory_usages ports
ports.each do |port|
  memory = JMX::MBean.find_by_name "java.lang:type=Memory", :port => port
  memory.gc
end
puts "After GC:"
display_memory_usages ports

