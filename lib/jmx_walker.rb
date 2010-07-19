require 'rubygems'
require 'jmx4r'

module JMX
  class Walker
    attr_reader :results

    # Beans are defined as follows:
    #
    # name:
    #       a jmx find string, such as java.lang:type=Memory
    #       it may also include wildcards such as java.lang:type=MemoryPool,name=*
    #       in this usage, it will process the path for each item found
    #
    # path:
    #       an array of elements to walk down the jmx tree.
    #       if an element is an array, the elements within that array are each
    #       applied at the current state

    def initialize(bean)
      @name=bean["name"]
      @path=bean["path"]
      @results = {}
      begin
        @state = JMX::MBean.find_all_by_name @name
      rescue Exception => e
      end
    end


    # walk the tree it returns a hash of path/value pairs
    def walk()
      @state.each do |state|
        desc = state.respond_to?(:name) ? state.name : @name
        boots(state,@path,desc)
      end
      return @results
    end


    # they're made for walking... recursively
    def boots(state,path,descr="")
      begin
        # get our current position
        curr = path.shift
        case
        when curr.instance_of?(String)
          descr="#{descr}.#{curr}"

          # we may have a hash or a mbean from which to get attributes
          # either way, we can "gettr" done
          state = (state.respond_to?(:keys) ? state[curr] : state.send(curr))
          if path.empty?
            @results[descr]=state
          else
            boots(state,path,descr)
          end
        when curr.instance_of?(Array)
          curr_state = state
          curr.each do |rabbit|
            hole = path.dup
            my_desc = "#{descr}.#{rabbit}"
            my_state = (curr_state.respond_to?(:keys) ? curr_state[rabbit] : curr_state.send(rabbit))
            if hole.empty?
              @results[my_desc]=my_state
            else
              boots(my_state,hole,my_desc)
            end
          end
        end
      rescue Exception => e
        puts "Exception required processing #{@name}: #{e}"
      end
    end
  end
end
