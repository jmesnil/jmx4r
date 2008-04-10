jmx4r is a JMX library for JRuby.

It can be used to write simple Ruby scripts running on JRuby[http://jruby.org]
to manage remote Java applications (e.g. JBoss[http://www.jboss.org],
Tomcat[http://tomcat.apache.org/]) using 
JMX[http://java.sun.com/javase/technologies/core/mntr-mgmt/javamanagement/].

== Examples 

To trigger a garbage collection on a Java application:

  require 'rubygems'
  require 'jmx4r'
  
  JMX::MBean.establish_connection :host => "localhost", :port => 3000
  memory = JMX::MBean.find_by_name "java.lang:type=Memory"
  memory.gc

