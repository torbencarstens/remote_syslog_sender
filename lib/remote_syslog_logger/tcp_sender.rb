require 'socket'
require 'syslog_protocol'
require 'remote_syslog_logger/sender'

module RemoteSyslogLogger
  class TcpSender < Sender
    def initialize(remote_hostname, remote_port, options = {})
      super
      @tls             = options[:tls]

      sock = TCPSocket.new(remote_hostname, remote_port)
      if @tls
        require 'openssl'
        context = OpenSSL::SSL::SSLContext.new(options[:ssl_method] || 'TLSv1_2')
        context.ca_file = options[:ca_file] if options[:ca_file]
        context.verify_mode = options[:verify_mode] if options[:verify_mode]
        @socket = OpenSSL::SSL::SSLSocket.new(sock, context)
        @socket.connect
        @socket.post_connection_check(remote_hostname)
        raise "verification error" if @socket.verify_result != OpenSSL::X509::V_OK
      else
        @socket = sock
      end
    end

    private

    def send_msg(payload)
      @socket.puts(payload)
    end
  end
end
