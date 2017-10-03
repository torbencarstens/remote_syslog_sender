require File.expand_path('../helper', __FILE__)

class TestRemoteSyslogLogger < Test::Unit::TestCase
  def setup
    @server_port = rand(50000) + 1024
    @socket = UDPSocket.new
    @socket.bind('127.0.0.1', @server_port)

    @tcp_server = TCPServer.open('127.0.0.1', 0)
    @tcp_server_port = @tcp_server.addr[1]

    @tcp_server_wait_thread = Thread.start do
      @tcp_server.accept
    end
  end

  def teardown
    @socket.close
    @tcp_server.close
  end

  def test_logger
    @logger = RemoteSyslogLogger.new('127.0.0.1', @server_port)
    @logger.write "This is a test"

    message, _ = *@socket.recvfrom(1024)
    assert_match(/This is a test/, message)
  end

  def test_logger_long_payload
    @logger = RemoteSyslogLogger.new('127.0.0.1', @server_port, packet_size: 10240)
    @logger.write "abcdefgh" * 1000

    message, _ = *@socket.recvfrom(10240)
    assert_match(/#{"abcdefgh" * 1000}/, message)
  end

  def test_logger_tcp
    @logger = RemoteSyslogLogger.new('127.0.0.1', @tcp_server_port, protocol: :tcp)
    @logger.write "This is a test"
    sock = @tcp_server_wait_thread.value

    message, _ = *sock.recvfrom(1024)
    assert_match(/This is a test/, message)
  end

  def test_logger_tcp_nonblock
    @logger = RemoteSyslogLogger.new('127.0.0.1', @tcp_server_port, protocol: :tcp, timeout: 20)
    @logger.write "This is a test"
    sock = @tcp_server_wait_thread.value

    message, _ = *sock.recvfrom(1024)
    assert_match(/This is a test/, message)
  end

  def test_logger_multiline
    @logger = RemoteSyslogLogger.new('127.0.0.1', @server_port)
    @logger.write "This is a test\nThis is the second line"

    message, _ = *@socket.recvfrom(1024)
    assert_match(/This is a test/, message)

    message, _ = *@socket.recvfrom(1024)
    assert_match(/This is the second line/, message)
  end
end
