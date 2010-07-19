require 'rubygems'
require 'jmx4r'
require 'active_support'


# create aliases for common JMX beans
# TODO: MemoryManager, MemoryPool, Logger
#       Also common jboss & weblogic

module JMX
  class Alias
    @@aliases = {
      :MEMORY_HEAP => [ "Heap memory usage, multiple values", [ "java.lang:type=Memory", "HeapMemoryUsage" ], :attribute],
      :MEMORY_HEAP_USED => [ "Used heap memory", [ "java.lang:type=Memory", "HeapMemoryUsage", "used" ], :attribute],
      :MEMORY_HEAP_INIT => [ "Initially allocated heap memory", [ "java.lang:type=Memory", "HeapMemoryUsage", "init" ], :attribute],
      :MEMORY_HEAP_COMITTED => [ "Committed heap memory. That's the memory currently available for this JVM", [ "java.lang:type=Memory", "HeapMemoryUsage", "committed" ], :attribute],
      :MEMORY_HEAP_MAX => [ "Maximum available heap memory", [ "java.lang:type=Memory", "HeapMemoryUsage", "max" ], :attribute],

      :MEMORY_NONHEAP => [ "Non-Heap memory usage, multiple values", [ "java.lang:type=Memory", "NonHeapMemoryUsage" ], :attribute],
      :MEMORY_NONHEAP_USED => [ "Used non-heap memory (like a 'method area')", [ "java.lang:type=Memory", "NonHeapMemoryUsage", "used" ], :attribute],
      :MEMORY_NONHEAP_INIT => [ "Initially allocated non-heap memory", [ "java.lang:type=Memory", "NonHeapMemoryUsage", "init" ], :attribute],
      :MEMORY_NONHEAP_COMITTED => [ "Committed non-heap memory", [ "java.lang:type=Memory", "NonHeapMemoryUsage", "committed" ], :attribute],
      :MEMORY_NONHEAP_MAX => [ "Maximum available non-heap memory", [ "java.lang:type=Memory", "NonHeapMemoryUsage", "max" ], :attribute],

      :MEMORY_VERBOSE => [ "Switch on/off verbose messages concerning the garbage collector", ["java.lang:type=Memory", "Verbose"], :attribute],

      # Class loading
      :CL_LOADED => [ "Number of currently loaded classes", [ "java.lang:type=ClassLoading", "LoadedClassCount"], :attribute],
      :CL_UNLOADED => [ "Number of unloaded classes", [ "java.lang:type=ClassLoading", "UnloadedClassCount"], :attribute],
      :CL_TOTAL => [ "Number of classes loaded in total", [ "java.lang:type=ClassLoading", "TotalLoadedClassCount"], :attribute],

      # Threads
      :THREAD_COUNT => ["Active threads in the system", [ "java.lang:type=Threading", "ThreadCount"], :attribute],
      :THREAD_COUNT_PEAK => ["Peak thread count", [ "java.lang:type=Threading", "PeakThreadCount"], :attribute],
      :THREAD_COUNT_STARTED => ["Count of threads started since system start", [ "java.lang:type=Threading", "TotalStartedThreadCount"], :attribute],
      :THREAD_COUNT_DAEMON => ["Count of threads marked as daemons in the system", [ "java.lang:type=Threading", "DaemonThreadCount"], :attribute],

      # Operating System
      :OS_MEMORY_PHYSICAL_FREE => ["The amount of free physical memory for the OS", [ "java.lang:type=OperatingSystem", "FreePhysicalMemorySize"], :attribute],
      :OS_MEMORY_PHYSICAL_TOTAL => ["The amount of total physical memory for the OS", [ "java.lang:type=OperatingSystem", "TotalPhysicalMemorySize"], :attribute],
      :OS_MEMORY_SWAP_FREE => ["The amount of free swap space for the OS", [ "java.lang:type=OperatingSystem", "FreeSwapSpaceSize"], :attribute],
      :OS_MEMORY_SWAP_TOTAL => ["The amount of total swap memory available", [ "java.lang:type=OperatingSystem", "TotalSwapSpaceSize"], :attribute],
      :OS_MEMORY_VIRTUAL => ["Size of virtual memory used by this process", [ "java.lang:type=OperatingSystem", "CommittedVirtualMemorySize"], :attribute],
      :OS_FILE_DESC_OPEN => ["Number of open file descriptors", [ "java.lang:type=OperatingSystem", "OpenFileDescriptorCount"], :attribute],
      :OS_FILE_DESC_MAX => ["Maximum number of open file descriptors", [ "java.lang:type=OperatingSystem", "MaxFileDescriptorCount"], :attribute],
      :OS_CPU_TIME => ["The cpu time used by this process", [ "java.lang:type=OperatingSystem", "ProcessCpuTime"], :attribute],
      :OS_INFO_PROCESSORS => ["Number of processors", [ "java.lang:type=OperatingSystem", "AvailableProcessors"], :attribute],
      :OS_INFO_ARCH => ["Architecture", [ "java.lang:type=OperatingSystem", "Arch"], :attribute],
      :OS_INFO_NAME => ["Operating system name", [ "java.lang:type=OperatingSystem", "Name"], :attribute],
      :OS_INFO_VERSION => ["Operating system version", [ "java.lang:type=OperatingSystem", "Version"], :attribute],

      # Runtime
      :RUNTIME_SYSTEM_PROPERTIES => ["System properties", [ "java.lang:type=Runtime", "SystemProperties"], :attribute],
      :RUNTIME_VM_VERSION => ["Version of JVM", [ "java.lang:type=Runtime", "VmVersion"], :attribute],
      :RUNTIME_VM_NAME => ["Name of JVM", [ "java.lang:type=Runtime", "VmName"], :attribute],
      :RUNTIME_VM_VENDOR => ["JVM Vendor", [ "java.lang:type=Runtime", "VmVendor"], :attribute],
      :RUNTIME_ARGUMENTS => ["Arguments when starting the JVM", [ "java.lang:type=Runtime", "InputArguments"], :attribute],
      :RUNTIME_UPTIME => ["Total uptime of JVM", [ "java.lang:type=Runtime", "Uptime"], :attribute],
      :RUNTIME_STARTTIME => ["Time when starting the JVM", [ "java.lang:type=Runtime", "StartTime"], :attribute],
      :RUNTIME_CLASSPATH => ["Classpath", [ "java.lang:type=Runtime", "ClassPath"], :attribute],
      :RUNTIME_BOOTCLASSPATH => ["Bootclasspath", [ "java.lang:type=Runtime", "BootClassPath"], :attribute],
      :RUNTIME_LIBRARY_PATH => ["The LD_LIBRARY_PATH", [ "java.lang:type=Runtime", "LibraryPath"], :attribute],
      :RUNTIME_NAME => ["Name of the runtime", [ "java.lang:type=Runtime", "Name"], :attribute],
      # Memory
      :MEMORY_GC => [ "Run a garbage collection", [ "java.lang:type=Memory", "gc" ], :operation],

      # Threads
      :THREAD_DEADLOCKED => [ "Find cycles of threads that are in deadlock waiting to acquire object monitors", [ "java.lang:type=Threading", "findMonitorDeadlockedThreads"], :operation]
    }
    attr_reader :name, :description, :properties, :bean

    def Alias.method_missing(message,args)
      if @@aliases.keys.include? message.to_sym
        a = @@aliases[message.to_sym]
        return Alias.new(a[1].dup).bean
      else
        super
      end
    end

    def initialize(bean_path)
      begin
        @bean = JMX::MBean.find_by_name bean_path.shift
        until bean_path.empty?
          curr=bean_path.shift.underscore
          @bean = @bean.respond_to?(:keys) ? @bean[curr] : @bean.send(curr)
        end

      rescue
        $stderr.print "Error finding bean: " + $!
      end
    end

    def Alias.aliases
      return @@aliases.keys
    end

    def Alias.pretty_print
      return @@aliases.inject("") do |s,v|
        "#{s}#{v[0]}: #{v[1][0]} (#{v[1][2].to_s})\n"
      end

    end

    def Alias.[](message)
      if @@aliases.keys.include? message.to_sym

        a = @@aliases[message.to_sym]
        return Alias.new(a[1].dup).bean
      else
        return nil
      end
    end

  end
end

