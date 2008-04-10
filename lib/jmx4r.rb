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
end

module JMX
  require 'open_data_helper'
  require 'jruby'

  class MBean
    include_class 'java.util.HashMap'
    include_class 'javax.management.Attribute'
    include_class 'javax.management.ObjectName'
    include_class 'javax.management.remote.JMXConnector'
    include_class 'javax.management.remote.JMXConnectorFactory'
    include_class 'javax.management.remote.JMXServiceURL'
    JThread = java.lang.Thread

    attr_reader :object_name, :operations, :attributes

    # Creates a new MBean.
    #
    # object_name:: a string corresponding to a valid ObjectName
    # mbsc::        a connection to a MBean server. If none is passed, 
    #               use the global connection created by 
    #               MBean.establish_connection
    def initialize(object_name, mbsc=nil)
      @mbsc = mbsc || @@mbsc
      @object_name = object_name
      info = @mbsc.getMBeanInfo @object_name
      @attributes = Hash.new
      info.attributes.each do | mbean_attr |
        @attributes[mbean_attr.name.snake_case] = mbean_attr.name
        self.class.instance_eval do 
          define_method mbean_attr.name.snake_case do
            @mbsc.getAttribute @object_name, "#{mbean_attr.name}"
          end
        end
        if mbean_attr.isWritable
          self.class.instance_eval do
            define_method "#{mbean_attr.name.snake_case}=" do |value| 
              attr = Attribute.new mbean_attr.name, value
              @mbsc.setAttribute @object_name, attr
            end
          end
        end
      end
      @operations = Hash.new
      info.operations.each do |mbean_op|
        param_types = mbean_op.signature.map {|param| param.type}
        @operations[mbean_op.name.snake_case] = [mbean_op.name, param_types]
      end
    end

    def method_missing(method, *args, &block) #:nodoc:
      if @operations.keys.include?(method.to_s)
        op_name, param_types = @operations[method.to_s]
        @mbsc.invoke @object_name,
        op_name,
        args.to_java(:Object),
        param_types.to_java(:String)
      else
        super
      end
    end

    @@mbsc = nil

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
    def self.establish_connection(args={})
      @@mbsc ||= create_connection args
    end

    def self.remove_connection(args={})
      @@mbsc = nil
    end

    def self.connection(args={})
      if args.has_key? :host or args.has_key? :port
        return create_connection(args)
      else
        MBean.establish_connection(args) unless @@mbsc
        return @@mbsc  
      end
    end

    # Create a connection to a remote MBean server.
    # 
    # The args accepts 4 keys:
    #
    # [:host]        the host of the MBean server (defaults to "localhost")
    # [:port]        the port of the MBean server (defaults to 3000)
    # [:username]    the name of the user (if the MBean server requires authentication).
    #                No default
    # [:password]    the password of the user (if the MBean server requires authentication).
    #                No default
    # [:credentials] custom credentials (if the MBean server requires authentication).
    #                No default. It has precedence over :username and :password (i.e. if
    #                :credentials is specified, :username & :password are ignored)   
    #
    def self.create_connection(args={})
      host= args[:host] || "localhost"
      port = args[:port] || 3000
      username = args[:username]
      password = args[:password]
      credentials = args[:credentials]
      
      url = "service:jmx:rmi:///jndi/rmi://#{host}:#{port}/jmxrmi"
      
      unless credentials
        if !username.nil? and username.length > 0
          user_password_credentials = [username, password]
          credentials = user_password_credentials.to_java(:String)
        end
      end
      
      env = HashMap.new
      env.put(JMXConnector::CREDENTIALS, credentials) if credentials

      # the context class loader is set to JRuby's classloader when
      # creating the JMX Connection so that classes loaded using 
      # JRuby "require" (and not from its classpath) can also be 
      # accessed (see issue #6)
      begin
        context_class_loader = JThread.current_thread.context_class_loader
        JThread.current_thread.context_class_loader = JRuby.runtime.getJRubyClassLoader
        
        connector = JMXConnectorFactory::connect JMXServiceURL.new(url), env
        connector.getMBeanServerConnection
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
      mbsc = args[:connection] || MBean.connection(args)
      object_names = mbsc.queryNames(object_name, nil)
      object_names.map { |on| MBean.new(on, mbsc) }
    end

    # Same as #find_all_by_name but the ObjectName passed in parameter
    # can not be a pattern.
    # Only one single MBean is returned.
    def self.find_by_name(name, args={})
      mbsc = args[:connection] || MBean.connection(args)
      MBean.new ObjectName.new(name), mbsc
    end
  end
end
