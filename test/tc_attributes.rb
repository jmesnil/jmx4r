# Copyright 2007 Jeff Mesnil (http://jmesnil.net)

require "test/unit"

require "jmx4r"
require "jconsole"

class TestAttribute < Test::Unit::TestCase
  import java.lang.management.ManagementFactory

  def setup
    @memory = JMX::MBean.find_by_name "java.lang:type=Memory", :connection => ManagementFactory.platform_mbean_server
  end

  def teardown
    JMX::MBean.remove_connection
  end

  def test_unknwown_attribute
    assert_raise(NoMethodError) { @memory.unknown_attribute }
  end

  def test_readable_attribute
    assert_equal false, @memory.verbose
  end

  def test_writable_attribute
    assert_equal false, @memory.verbose
    @memory.verbose = true
    assert_equal true, @memory.verbose
    @memory.verbose = false
  end

  def test_non_writable_attribute
    assert_raise(NoMethodError) { @memory.object_pending_finalization_count = -1 }
  end

  def test_non_overlapping_attributes
    assert_raise(NoMethodError) { @memory.logger_names }
    logging = JMX::MBean.find_by_name "java.util.logging:type=Logging", :connection => ManagementFactory.platform_mbean_server
    assert_raise(NoMethodError) { logging.verbose }
    assert_raise(NoMethodError) { @memory.logger_names }
  end
end
