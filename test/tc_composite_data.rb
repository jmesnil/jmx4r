# Copyright 2007 Jeff Mesnil (http://jmesnil.net)

require "test/unit"

require "jmx4r"
require "jconsole"

class TestCompositeData < Test::Unit::TestCase
  import java.lang.management.ManagementFactory

  def setup
    memory = JMX::MBean.find_by_name "java.lang:type=Memory", :connection => ManagementFactory.platform_mbean_server
    # heap_memory_usage is a CompositeData
    @heap = memory.heap_memory_usage
  end

  def teardown
    @heap = nil
    JMX::MBean.remove_connection
  end
  
  # use #map to check that CompositeData includes Enumerable
  def test_enumerable_composite_data
    expected_headers = ["init", "committed", "used", "max"].sort
    headers = @heap.map { |k, v| k }.sort
    assert_equal expected_headers, headers
  end

  def test_composite_data_keys
    expected_headers = ["init", "committed", "used", "max"].sort
    headers = @heap.keys.sort
    assert_equal expected_headers, headers
  end

  def test_composite_data_key_aliases
    assert @heap.key?("used")
    assert @heap.has_key?("used")
    assert @heap.include?("used")
    assert @heap.member?("used")
  end
  
  def test_composite_data_method_missing
    assert @heap.used
    
    def @heap.containsKey(key)
      "camelCaseAttributeName" == key
    end

    def @heap.get(key)
      return "value" if "camelCaseAttributeName" == key
      raise("should not happen")
    end
    
    assert_equal "value", @heap.camel_case_attribute_name
    
    assert_raises NoMethodError do
      @heap.unknown_attribute
    end
  end
  
  def test_composite_data_as_hash
    used = @heap.get "used"
    used_from_hash = @heap["used"]
    assert_equal used, used_from_hash
  end  

  def test_composite_data_as_hash_with_known_key
    assert_equal true, @heap.key?("used")
    used = @heap["used"]
  end
  
  def test_composite_data_as_hash_with_unknown_key
    assert_equal false, @heap.key?("unknown")
    assert_raise(NativeException) { @heap["unknown"] }
  end
end