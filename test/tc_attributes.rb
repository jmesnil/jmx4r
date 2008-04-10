# Copyright 2007 Jeff Mesnil (http://jmesnil.net)

require "test/unit"

require "jmx4r"
require "jconsole"

class TestAttribute < Test::Unit::TestCase
  def setup
    JConsole::start
    @memory = JMX::MBean.find_by_name "java.lang:type=Memory"
  end

  def teardown
    JMX::MBean.remove_connection
    JConsole::stop
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
  end

  def test_non_writable_attribute
    assert_raise(NoMethodError) { @memory.object_pending_finalization_count = -1 }
  end
end
