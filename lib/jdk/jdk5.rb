
module JMX
  module JDKHelper
    module JDK5
      java_import sun.jvmstat.monitor.HostIdentifier
      java_import sun.jvmstat.monitor.MonitoredHost
      java_import sun.jvmstat.monitor.MonitoredVmUtil
      java_import sun.jvmstat.monitor.VmIdentifier
      java_import sun.management.ConnectorAddressLink

      class << self

        def find_local_url(command_pattern)
          host_id = HostIdentifier.new(nil)
          host = MonitoredHost.get_monitored_host(host_id)

          host.active_vms.each do |vmid_int|
            vmid = VmIdentifier.new(vmid_int.to_s)
            vm = host.get_monitored_vm(vmid)
            command = MonitoredVmUtil.command_line(vm)
            if command_pattern === command
              return ConnectorAddressLink.import_from(vmid_int)
            end
          end

          nil
        end

      end

    end
  end
end

