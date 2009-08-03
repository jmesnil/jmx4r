
module JMX
  module JDKHelper
    module JDK5
      include_class 'sun.jvmstat.monitor.HostIdentifier'
      include_class 'sun.jvmstat.monitor.MonitoredHost'
      include_class 'sun.jvmstat.monitor.MonitoredVmUtil'
      include_class 'sun.jvmstat.monitor.VmIdentifier'
      include_class 'sun.management.ConnectorAddressLink'

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

