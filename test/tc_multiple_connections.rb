# Copyright 2007 Jeff Mesnil (http://jmesnil.net)

require "test/unit"

require "jmx4r"
require "jconsole"

class TestMultipleConnections < Test::Unit::TestCase
  def setup
    @ports = [3001, 3002]
    @ports.each {|port| JConsole::start :port => port }

    # the MBeanServerDelegate ID is unique for each MBean Server
    @delegate_on = "JMImplementation:type=MBeanServerDelegate"
  end

  def teardown
    @ports.each do |port| 
      JConsole::stop port 
    end
  end

  def test_same_connection_port
    delegate_1 = JMX::MBean.find_by_name @delegate_on, :port => @ports[0]
    delegate_2 = JMX::MBean.find_by_name @delegate_on, :port => @ports[0]

    assert_equal delegate_1.m_bean_server_id, delegate_2.m_bean_server_id
  end

  def test_different_connection_port
    delegate_1 = JMX::MBean.find_by_name @delegate_on, :port => @ports[0]
    delegate_2 = JMX::MBean.find_by_name @delegate_on, :port => @ports[1]

    assert_not_equal delegate_1.m_bean_server_id, delegate_2.m_bean_server_id
  end

  def test_same_connection
    mbsc = JMX::MBean.create_connection :port => @ports[0]

    delegate_1 = JMX::MBean.find_by_name @delegate_on, :connection => mbsc
    delegate_2 = JMX::MBean.find_by_name @delegate_on, :connection => mbsc

    assert_equal delegate_1.m_bean_server_id, delegate_2.m_bean_server_id
  end

  def test_different_connection
    mbsc_1 = JMX::MBean.create_connection :port => @ports[0]
    mbsc_2 = JMX::MBean.create_connection :port => @ports[1]

    delegate_1 = JMX::MBean.find_by_name @delegate_on, :connection => mbsc_1
    delegate_2 = JMX::MBean.find_by_name @delegate_on, :connection => mbsc_2

    assert_not_equal delegate_1.m_bean_server_id, delegate_2.m_bean_server_id
  end

  def test_global_connection
    JMX::MBean.establish_connection :port => @ports[0]

    delegate_1 = JMX::MBean.find_by_name @delegate_on
    delegate_2 = JMX::MBean.find_by_name @delegate_on

    assert_equal delegate_1.m_bean_server_id, delegate_2.m_bean_server_id
    JMX::MBean.remove_connection
  end

end
