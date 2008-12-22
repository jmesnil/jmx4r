#!/usr/bin/env jruby

# Run with:
# jruby -J-Dcom.sun.management.jmxremote  -Ilib examples/ruby_mbean.rb
#
# and open jconsole to manage the MBean

require 'rubygems'
require 'jmx4r'

import java.lang.management.ManagementFactory
import javax.management.ObjectName

class ExampleMBean < DynamicMBean
  rw_attribute :string_attr, :string, "a String attribute"
  rw_attribute :int_attr, :int, "a Integer attribute"
  rw_attribute :long_attr, :long, "a Long attribute"
  rw_attribute :float_attr, :float, "a Float attribute"
  rw_attribute :double_attr, :double, "a Double attribute"
  rw_attribute :boolean_attr, :boolean, "a Boolean attribute"

  operation "reverse the string passed in parameter"
  parameter :string, "arg", "a String to reverse"
  returns :string
  def reverse(arg)
    arg.reverse
  end
end

mbean = ExampleMBean.new
object_name = ObjectName.new("jmx4r:name=ExampleMBean")

mbeanServer = ManagementFactory.platform_mbean_server
mbeanServer.register_mbean mbean, object_name
puts "Open jconsole to manage the MBean #{object_name}"
puts "When you have finished, type <ENTER> to exit"
gets

mbeanServer.unregister_mbean object_name
puts "unregistered #{object_name}"

