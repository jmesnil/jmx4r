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
      connection = JMX::MBean.establish_connection
      assert(connection.getMBeanCount > 0)
    ensure
      JConsole::stop
    end
  end

  def test_remove_connection
    begin
      JConsole::start
      connection = JMX::MBean.establish_connection
      JMX::MBean.remove_connection
      assert_raise(NativeException) {
        connection.getMBeanCount
      }
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

  def test_establish_connection_with_custom_url
    begin
      JConsole::start :port => 3001
      url = "service:jmx:rmi:///jndi/rmi://localhost:3001/jmxrmi"
      JMX::MBean.establish_connection :url => url
    ensure
      JConsole::stop 3001
    end
  end

  def test_establish_connection_with_custom_url_overrides_host_and_port
    begin
      JConsole::start :port => 3001
      good_url = "service:jmx:rmi:///jndi/rmi://localhost:3001/jmxrmi"
      bad_port = 3000
      # specifying a :url discards the :port & :host parameters
      JMX::MBean.establish_connection :port => bad_port, :url => good_url
    ensure
      JConsole::stop 3001
    end
  end

  def test_establish_connection_local
    begin
      JConsole::start :port => 0
      connection = JMX::MBean.establish_connection \
        :command => /jconsole/i
      assert(connection.getMBeanCount > 0)
    ensure
      JConsole::stop 0
    end
  end

end
