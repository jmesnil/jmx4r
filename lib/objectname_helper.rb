# Copyright 2008 Jeff Mesnil (http://jmesnil.net)
#
# This file adds methods to ObjectName proxies
require 'java'

JavaUtilities.extend_proxy('javax.management.ObjectName') do
  def key?(k)
    self.contains_key k
  end
  alias has_key? key?
  alias include? key?
  alias member? key?
  
  def keys
    self.get_key_property_list.key_set
  end
  
  def [](key)
    self.get_key_property key
  end
end