#!/usr/bin/env jruby
require 'rubygems'
require 'jmx4r'

def display header, memory_usage
  puts header
  memory_usage.sort.each do |key, value|
    puts "\t#{key} : #{value}"
  end
end
memory = JMX::MBean.find_by_name "java.lang:type=Memory"

display "Heap Memory Usage", memory.heap_memory_usage
display "Non Heap Memory Usage", memory.non_heap_memory_usage

if ARGV.length == 1 and ARGV[0] == "gc"
  puts "trigger a garbage collection"
  memory.gc
  display "Heap Memory Usage", memory.heap_memory_usage
  display "Non Heap Memory Usage", memory.non_heap_memory_usage   
end