
module JMX
  module JDK6Helper
    include_class 'com.sun.tools.attach.VirtualMachine'

    class << self
      def find_local_url(command_pattern)
        target_vmd = VirtualMachine.list.find do |vmd|
          command_pattern === vmd.display_name
        end

        if target_vmd
          local_connector_address(target_vmd)
        end
      end

    private

      def local_connector_address(vm_descriptor)
        agent_loaded = false
        vm = VirtualMachine.attach(vm_descriptor)

        begin
          address = vm.get_agent_properties.get(
            "com.sun.management.jmxremote.localConnectorAddress")

          unless address || agent_loaded
            home =
              vm.get_system_properties.get_property 'java.home'
            load_management_agent(vm, [home, 'jre', 'lib']) or
              load_management_agent(vm, [home, 'lib']) or
                raise "management agent not found"
            agent_loaded = true
            redo
          end
        end

        vm.detach

        address
      end

      def load_management_agent(vm, path)
        sep = vm.get_system_properties.get_property 'file.separator'

        path = path.dup
        path << 'management-agent.jar'

        file = Java::java.io.File.new(path.join(sep))
        if file.exists
          vm.load_agent(file.get_canonical_path,
                        "com.sun.management.jmxremote")
          true
        end
      end

    end
  end
end

