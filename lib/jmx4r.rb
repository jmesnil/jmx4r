# Copyright 2007 Jeff Mesnil (http://jmesnil.net)
require 'java'

class String
  # Transform a CamelCase String to a snake_case String.
  #--
  # Code has been taken from ActiveRecord
  def snake_case
    self.to_s.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
  
  # Transform a snake_case String to a camelCase String with a lowercase initial.
  #--
  # Code has been taken from ActiveSupport
  def camel_case
    name = gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    name[0].chr.downcase + name[1..-1]
  end
end

module JMX
  require 'dynamic_mbean'
  require 'open_data_helper'
  require 'objectname_helper'
  require 'jdk_helper'
  require 'jruby'

  class MBeanServerConnectionProxy
    attr_reader :connector

    # Adds a connector attribute to Java's native MBeanServerConnection class.
    #
    # The connector attribute can be used to manage the connection (e.g, to close it).
    # Why this isn't included in the native MBeanServerConnection class is beyond me.
    #
    # connector:: JMXConnector instance as returned by JMXConnectorFactory.connect.
    def initialize(connector)
      @connector = connector
      @connection = connector.getMBeanServerConnection
    end

    # Close the connection (an unfortunate omission from the MBeanServerConnection class, imho)
    def close
      @connector.close
    end

    # Forward all other method messages to the underlying MBeanServerConnection instance.
    def method_missing(method, *args, &block)
      @connection.send method, *args, &block
    end
  end

  class MBean
    java_import java.util.HashMap
    java_import javax.naming.Context
    java_import javax.management.Attribute
    java_import javax.management.ObjectName
    java_import javax.management.remote.JMXConnector
    java_import javax.management.remote.JMXConnectorFactory
    java_import javax.management.remote.JMXServiceURL
    JThread = java.lang.Thread

    attr_reader :object_name, :operations, :attributes, :connection

    def metaclass; class << self; self; end; end
    def meta_def name, &blk
      metaclass.instance_eval do
          define_method name, &blk
      end
    end

    # Creates a new MBean.
    #
    # object_name:: a string corresponding to a valid ObjectName
    # connection::  a connection to a MBean server. If none is passed,
    #               use the global connection created by 
    #               MBean.establish_connection
    def initialize(object_name, connection=nil)
      @connection = connection || @@connection
      @object_name = object_name
      info = @connection.getMBeanInfo @object_name
      @attributes = Hash.new
      info.attributes.each do | mbean_attr |
        @attributes[mbean_attr.name.snake_case] = mbean_attr.name
      end
      @operations = Hash.new
      info.operations.each do |mbean_op|
        param_types = mbean_op.signature.map {|param| param.type}
        @operations[mbean_op.name.snake_case] = [mbean_op.name, param_types]
      end
    end

    def method_missing(method, *args, &block) #:nodoc:
      method_in_snake_case = method.to_s.snake_case # this way Java/JRuby styles are compatible

      if @operations.keys.include?(method_in_snake_case)
        op_name, param_types = @operations[method_in_snake_case]
        @connection.invoke @object_name,
                           op_name,
                           args.to_java(:Object),
                           param_types.to_java(:String)
      else
        super
      end
    end

    @@connection = nil

    # establish a connection to a remote MBean server which will
    # be used by all subsequent MBeans.
    # 
    # See MBean.create_connection for a list of the keys that are
    # accepted in arguments.
    #
    # Examples
    # 
    #   JMX::MBean.establish_connection :port => "node23", :port => 1090
    #   JMX::MBean.establish_connection :port => "node23", :username => "jeff", :password => "secret"
    #   JMX::MBean.establish_connection :command => /jconsole/i
    def self.establish_connection(args={})
      @@connection ||= create_connection args
    end

    def self.remove_connection(args={})
      if @@connection
        @@connection.close rescue nil
      end
      @@connection = nil
    end

    def self.connection(args={})
      if args.has_key? :host or args.has_key? :port
        return create_connection(args)
      else
        @@connection ||= MBean.establish_connection(args)
      end
    end

    # Create a connection to a remote MBean server.
    # 
    # The args accepts the following keys:
    #
    # [:host]             the host of the MBean server (defaults to "localhost")
    #
    # [:port]             the port of the MBean server (defaults to 3000)
    #
    # [:url]              the url of the MBean server.
    #                     No default.
    #                     if the url is specified, the host & port parameters are
    #                     not taken into account
    #
    # [:command]          the pattern matches the command line of the local
    #                     JVM process including the MBean server.
    #                     (command lines are listed on the connection dialog
    #                     in JConsole).
    #                     No default.
    #                     this feature needs a JDK (>=5) installed on the local
    #                     system.
    #                     if the command is specified, the host & port or the url
    #                     parameters are not taken into account
    #
    # [:username]         the name of the user (if the MBean server requires authentication).
    #                     No default
    #
    # [:password]         the password of the user (if the MBean server requires authentication).
    #                     No default
    #
    # [:credentials]      custom credentials (if the MBean server requires authentication).
    #                     No default. It has precedence over :username and :password (i.e. if
    #                     :credentials is specified, :username & :password are ignored)   
    #
    # [:provider_package] use to fill the JMXConnectorFactory::PROTOCOL_PROVIDER_PACKAGES.
    #                     No default
    #
    def self.create_connection(args={})
      host= args[:host] || "localhost"
      port = args[:port] || 3000
      username = args[:username]
      password = args[:password]
      credentials = args[:credentials]
      provider_package = args[:provider_package]
      
      if args[:command]
        url = JDKHelper.find_local_url(args[:command]) or
          raise "no locally attacheable VMs"
      else
        # host & port are not taken into account if url is set (see issue #7)
        standard_url = "service:jmx:rmi:///jndi/rmi://#{host}:#{port}/jmxrmi"
        url = args[:url] || standard_url
      end
      
      unless credentials
        if !username.nil? and username.length > 0
          user_password_credentials = [username, password]
          credentials = user_password_credentials.to_java(:String)
        end
      end
      
      env = HashMap.new
      env.put(JMXConnector::CREDENTIALS, credentials) if credentials
      # only fill the Context and JMXConnectorFactory properties if provider_package is set
      if provider_package
        env.put(Context::SECURITY_PRINCIPAL, username) if username
        env.put(Context::SECURITY_CREDENTIALS, password) if password
        env.put(JMXConnectorFactory::PROTOCOL_PROVIDER_PACKAGES, provider_package)
      end

      # the context class loader is set to JRuby's classloader when
      # creating the JMX Connection so that classes loaded using 
      # JRuby "require" (and not from its classpath) can also be 
      # accessed (see issue #6)
      begin
        context_class_loader = JThread.current_thread.context_class_loader
        JThread.current_thread.context_class_loader = JRuby.runtime.getJRubyClassLoader
        
        connector = JMXConnectorFactory::connect JMXServiceURL.new(url), env
        MBeanServerConnectionProxy.new connector
      ensure
        # ... and we reset the previous context class loader
        JThread.current_thread.context_class_loader = context_class_loader
      end
    end

    # Returns an array of MBeans corresponding to all the MBeans
    # registered for the ObjectName passed in parameter (which may be 
    # a pattern).
    #
    # The args accepts the same keys than #create_connection and an 
    # additional one:
    #
    # [:connection] a MBean server connection (as returned by #create_connection)
    #               No default. It has precedence over :host and :port (i.e if
    #               :connection is specified, :host and :port are ignored)
    #
    def self.find_all_by_name(name, args={})
      object_name = ObjectName.new(name)
      connection = args[:connection] || MBean.connection(args)
      object_names = connection.queryNames(object_name, nil)
      object_names.map { |on| create_mbean on, connection }
    end

    # Same as #find_all_by_name but the ObjectName passed in parameter
    # can not be a pattern.
    # Only one single MBean is returned.
    def self.find_by_name(name, args={})
      connection = args[:connection] || MBean.connection(args)
      create_mbean ObjectName.new(name), connection
    end

    def self.create_mbean(object_name, connection)
      info = connection.getMBeanInfo object_name
      mbean = MBean.new object_name, connection
      # define attribute accessor methods for the mbean
      info.attributes.each do |mbean_attr|
        mbean.meta_def mbean_attr.name.snake_case do
          connection.getAttribute object_name, mbean_attr.name
        end
        if mbean_attr.isWritable
          mbean.meta_def "#{mbean_attr.name.snake_case}=" do |value|
            attribute = Attribute.new mbean_attr.name, value
            connection.setAttribute object_name, attribute
          end
        end
      end
      mbean
    end

    def self.pretty_print (object_name, args={})
      connection = args[:connection] || MBean.connection(args)
      info = connection.getMBeanInfo ObjectName.new(object_name)
      puts "object_name: #{object_name}"
      puts "class: #{info.class_name}"
      puts "description: #{info.description}"
      puts "operations:"
      info.operations.each do | op |
        puts "  #{op.name}"
        op.signature.each do | param |
          puts "    #{param.name} (#{param.type} #{param.description})"
        end
        puts "    ----"
        puts "    description: #{op.description}"
        puts "    return_type: #{op.return_type}"
        puts "    impact: #{op.impact}"
      end
      puts "attributes:"
      info.attributes.each do | attr |
        puts "  #{attr.name}"
        puts "    description: #{attr.description}"
        puts "    type: #{attr.type}"
        puts "    readable: #{attr.readable}"
        puts "    writable: #{attr.writable}"
        puts "    is: #{attr.is}"
      end
    end
  end
end
