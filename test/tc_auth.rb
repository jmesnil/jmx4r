# Copyright 2007 Jeff Mesnil (http://jmesnil.net)

require "test/unit"

require "jmx4r"
require "jconsole"

class TestAuthentication < Test::Unit::TestCase

  def setup
    @username = "jmx4r.user"
    @password = "jmx4r.password"

    pwd_path = "/tmp/jmx4r.password"
    @pwd_file = File.new(pwd_path, "w")
    @pwd_file.puts "#{@username} #{@password}"
    @pwd_file.close

    # pwd file must be readable only by user
    # but somehow File.chmod is not working
    # with JRuby
    `chmod 0600 #{@pwd_file.path}`

    access_path = "/tmp/jmx4r.access"
    @access_file = File.new(access_path, "w")
    @access_file.puts "#{@username} readwrite"
    @access_file.close
    # access file must be readable only by user
    `chmod 0600 #{@access_file.path}`

    JConsole::start :pwd_file => @pwd_file.path, :access_file => @access_file.path
  end

  def teardown
    JMX::MBean.remove_connection
    JConsole::stop
    File.delete @pwd_file.path if File.file? @pwd_file.path
    File.delete @access_file.path if File.file? @access_file.path
  end
  
  def test_establish_auth_connection_with_correct_credentials
    JMX::MBean.establish_connection :username => @username, :password => @password 
  end
  
  # test that using the :credentials key to pass the username/password
  # credentials is working the same way than passing :username/:password
  def test_establish_auth_connection_with_custom_credentials
    credentials = [@username, @password].to_java(:String)
    JMX::MBean.establish_connection :credentials => credentials
  end

  def test_establish_auth_connection_with_invalid_username
    assert_raise(NativeException) {
      JMX::MBean.establish_connection :username => "invalid user name", :password => @password
    }
  end

  def test_establish_auth_connection_with_invalid_password
    assert_raise(NativeException) {
      JMX::MBean.establish_connection :username => @username, :password => "invalid password" 
    }
  end

  def test_establish_auth_connection_with_no_credentials
    assert_raise(NativeException) {
      JMX::MBean.establish_connection
    }
  end
end
