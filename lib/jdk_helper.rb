
module JMX
  module JDKHelper
    java_import java.lang.System

    class << self

      def method_missing(method, *args, &block)
        init unless @jdk
        @jdk.send method, *args, &block
      end

    private

      def init
        @jdk =
          case
          when has_java_class?("com.sun.tools.attach.VirtualMachine")
            require "jdk/jdk6"
            JDK6
          when has_java_class?('sun.jvmstat.monitor.MonitoredHost')
            require "jdk/jdk5"
            JDK5
          else
            require "jdk/jdk4"
            JDK4
          end
      end

      def has_java_class?(name)
        begin
          java_import name
          true
        rescue
          retry if load_tools_jar
          false
        end
      end

      def load_tools_jar
        unless @tools_loaded
          home = System.get_property 'java.home'
          paths = [
            [home, '..', 'lib'],
            [home, 'lib'],
          ]
          try_load_jar('tools.jar', paths)
          @tools_loaded = true
          true
        end
      end

      def try_load_jar(jar_file, paths)
        sep = System.get_property 'file.separator'
        paths = paths.dup
        begin
          path = paths.shift
          require path.join(sep) + sep + jar_file
          true
        rescue LoadError
          retry unless paths.empty?
          false
        end
      end
    end

  end
end

