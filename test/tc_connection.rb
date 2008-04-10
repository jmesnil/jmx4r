# Copyright 2007 Jeff Mesnil (http://jmesnil.net)

require "test/unit"

require "jmx4r"
require "jconsole"

class TestConnection < Test::Unit::TestCase
  def teardown
    JMX::MBean.remove_connection
  end

  def test_establish_connection_with_bad_port
    assert_raise(NativeException) { 
      JMX::MBean.establish_connection :port => 9999
    }
  end

  def test_establish_connection_with_bad_host
    assert_raise(NativeException) { 
      JMX::MBean.establish_connection :host => "not a valid host"
    }
  end

  def test_establish_connection
    begin
      JConsole::start
      JMX::MBean.establish_connection
    ensure
      JConsole::stop
    end
  end

  def test_establish_connection_with_custom_port
    begin
      JConsole::start :port => 3001
      JMX::MBean.establish_connection :port => 3001
    ensure
      JConsole::stop 3001
    end
  end
end
