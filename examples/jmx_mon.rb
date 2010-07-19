require 'rubygems'
require 'jmx4r'
require 'active_support'
require 'pp'
require 'jmx_alias'
require 'jmx_walker'


# This example jmx monitor uses a yaml config file to obtain information from 
# one or more beans from one or more jvms

begin
  config=YAML.load_file(ARGV[0])
rescue Exception => e
  puts "Can't load config file: #{ARGV[0]}"
  exit 1
end

# for each host defined in our config file do the following
config["hosts"].each do |host|
  begin
    puts "connecting to #{host["name"]}"
    # we use the info from the yaml connection hash here
    JMX::MBean.establish_connection host["connection"]

    # now step through each bean in turn
    host["beans"].each do |bean|
      pp bean
      case
        when bean.instance_of?(Symbol)
          puts JMX::Alias[bean] # not sure here
        when bean.instance_of?(Hash)
          pp JMX::Walker.new(bean).walk
        else
          puts "Unknown type"
      end
    end

    JMX::MBean.remove_connection
  rescue Exception => e
    puts "Connection to #{host["name"]} is down.: #{e}"
  end
end
