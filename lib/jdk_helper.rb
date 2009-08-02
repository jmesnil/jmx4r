
module JMX
  module JDKHelper
    class << self
      include_class 'java.lang.System'

      def init
        @helper = nil

        if has_java_class?("com.sun.tools.attach.VirtualMachine")
          require "jdk/jdk6_helper"
          @helper = JDK6Helper
          return
        end

        if has_java_class?('sun.jvmstat.monitor.MonitoredHost')
          require "jdk/jdk5_helper"
          @helper = JDK5Helper
          return
        end
      end

      def method_missing(method, *args, &block)
        unless @helper
          raise "JDKHelper implementation is not available - \
            maybe only JREs are installed properly."
        end
        @helper.send method, *args, &block
      end

    private

      def has_java_class?(name)
        begin
          include_class name
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

    self.init
  end

end

