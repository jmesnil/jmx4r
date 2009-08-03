
module JMX
  module JDKHelper
    module JDK4

      class << self
        def method_missing(method, *args, &block)
          raise "JDK (>= 5.0) implementation is not available - \
            maybe only JREs or older JDKs are installed properly."
        end
      end

    end
  end
end

