# Copyright 2007 Jeff Mesnil (http://jmesnil.net)
#
# This file adds methods to CompositeData proxies so that they can behave like
# regular (read-only) Ruby Hash
require 'java'

JavaUtilities.extend_proxy('javax.management.openmbean.CompositeDataSupport') do
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
end

JavaUtilities.extend_proxy('javax.management.openmbean.TabularDataSupport') do
  include Enumerable
  def each
    self.values.each do |value|
      yield value
    end
    self
  end
end