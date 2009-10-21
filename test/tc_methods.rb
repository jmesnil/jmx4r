# Copyright 2007 Jeff Mesnil (http://jmesnil.net)

require "test/unit"

require "jmx4r"
require "jconsole"

class TestMethods < Test::Unit::TestCase
  java_import java.lang.management.ManagementFactory

  def setup
    @logging = JMX::MBean.find_by_name "java.util.logging:type=Logging", :connection => ManagementFactory.platform_mbean_server
  end

  def teardown
    JMX::MBean.remove_connection
  end

  def test_invoke_operation
    @logging.set_logger_level "global", "FINEST"
    assert_equal "FINEST", @logging.get_logger_level("global")
  end

  # make sure we can also use Java name convention
  def test_invoke_CamelCaseOperation
    @logging.setLoggerLevel "global", "FINE"
    assert_equal "FINE", @logging.getLoggerLevel("global")
  end

end
