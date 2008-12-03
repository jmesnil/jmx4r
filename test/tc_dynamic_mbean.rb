# Copyright 2008 Jeff Mesnil (http://jmesnil.net)

require "test/unit"

require "jmx4r"

class DynamicTestBean < RubyDynamicMBean
  rw_attribute :name, :string, "a String attribute"

  operation
  parameter :string, "arg", "Name of user requesting shutdown"
  returns :void
  def foo(arg)
    @name = arg
    "invoked foo with #{arg}, updated name attribute"
  end
end

class TestDynamicMBean < Test::Unit::TestCase

  import java.lang.management.ManagementFactory
  import javax.management.ObjectName

  def test_simple
      mbean = DynamicTestBean.new
      mbeanServer = ManagementFactory.platform_mbean_server
      mbeanServer.register_mbean mbean, ObjectName.new("jmx4r:name=Foo")

      set = mbeanServer.query_names ObjectName.new("jmx4r:*"), nil
      assert_equal(1, set.length)

      foo = JMX::MBean.find_by_name "jmx4r:name=Foo", :connection => mbeanServer
      foo.name = "test"
      assert_equal("test", foo.name)
      foo.foo "blah"
      assert_equal("blah", foo.name)
  end
end