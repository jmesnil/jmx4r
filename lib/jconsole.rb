# JConsole module is used by jmx4r unit tests.
#
# {jconsole}[http://java.sun.com/j2se/1.5.0/docs/guide/management/jconsole.html] 
# is used as the target remote Java application manageable by JMX 
# (we do not used it for its JMX capability, just because it is a ready to 
# use Java application available with every JDK).
#
# Copyright 2007 Jeff Mesnil (http://jmesnil.net)
module JConsole
  
  # Start a new instance of jconsole which is accessible on port 3000.
  # By default, no authentication is required to connect to it.
  #
  # The args hash accepts 3 keys:
  # [:port]        the port which will be listens to JMX connections.
  #                if the port is 0, jmxrmi port is not published
  # [:pwd_file]    the path to the file containing the authentication credentials
  # [:access_file] the path to the file containing the authorization credentials
  #
  # The file path corresponding to :pwd_file must have <b>600 permission</b> 
  # (<tt>chmod 600 jmxremote.password</tt>).
  # 
  # Both <tt>:pwd_file</tt> and <tt>:access_file+</tt> must be specified to run a secure 
  # jconsole (see {JMX password & access files}[http://java.sun.com/j2se/1.5.0/docs/guide/management/agent.html#PasswordAccessFiles])
  def JConsole.start(args={})
    port = args[:port] || 3000
    pwd_file = args[:pwd_file]
    access_file = args[:access_file]

    cmd =<<-EOCMD.split("\n").join(" ")
    jconsole
    -J-Dcom.sun.management.jmxremote 
    EOCMD

    if port != 0
      cmd << <<-EOCMD.split("\n").join(" ")
      -J-Dcom.sun.management.jmxremote.port=#{port}
      -J-Dcom.sun.management.jmxremote.ssl=false
      -J-Dcom.sun.management.jmxremote.authenticate=#{!pwd_file.nil?}
      EOCMD

      if pwd_file and access_file
        cmd << " -J-Dcom.sun.management.jmxremote.password.file=#{pwd_file}"
        cmd << " -J-Dcom.sun.management.jmxremote.access.file=#{access_file}"
      end
    end
    Thread.start { system cmd }
    sleep 3
  end

  # Stop an instance of JConsole (by killing its process)
  #
  # By default, it will kill the process corresponding to an instance JConsole with 
  # a port on 3000. Another port can be specified in parameter.
  def JConsole.stop(port=3000)
    ps  = "ps a -w -o pid,command | grep -w jconsole"
    ps << " | grep port=#{port}" if port != 0
    ps << " | grep -v grep | grep -v ruby | cut -c -5"

    jconsole_pid = `#{ps}`
    `kill #{jconsole_pid}` if jconsole_pid != ""
    sleep 1
  end
end

if ARGV.length == 1
  case ARGV[0]
  when "start"
    JConsole::start
    puts "started jconsole"
  when "stop"
    JConsole::stop
    puts "stopped jconsole"
  end
end
