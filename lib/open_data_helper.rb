# Copyright 2007 Jeff Mesnil (http://jmesnil.net)
#
# This file adds methods to CompositeData proxies so that they can behave like
# regular (read-only) Ruby Hash
require 'java'

JavaUtilities.extend_proxy('javax.management.openmbean.CompositeData') do
  include Enumerable
  def each
    self.get_composite_type.key_set.each do |k|
      yield(k,self.get(k))
    end
    self
  end

  def key?(k)
    self.contains_key k
  end
  alias has_key? key?
  alias include? key?
  alias member? key?
  
  def keys
    self.get_composite_type.key_set
  end
  
  def [](key)
    self.get key
  end
  
  def method_missing(name, *args)
    key = name.to_s.camel_case
    super unless containsKey(key)
    get(name.to_s.camel_case)
  end
  
  def respond_to?(symbol, include_private = false)
    containsKey(symbol.to_s.camel_case) || super
  end
end

JavaUtilities.extend_proxy('javax.management.openmbean.TabularData') do
  include Enumerable
  def each
    self.values.each do |value|
      yield value
    end
    self
  end
end