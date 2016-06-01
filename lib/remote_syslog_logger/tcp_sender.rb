require 'socket'
require 'syslog_protocol'
require 'remote_syslog_logger/sender'

module RemoteSyslogLogger
  class TcpSender < Sender
    def initialize(remote_hostname, remote_port, options = {})
      super
      @tls             = options[:tls]
      @retry_limit     = options[:retry_limit] || 3
      @remote_hostname = remote_hostname
      @remote_port     = remote_port
      @ssl_method      = options[:ssl_method] || 'TLSv1_2'
      @ca_file         = options[:ca_file]
      @verify_mode     = options[:verify_mode]
      connect
    end

    private

    def connect
      sock = TCPSocket.new(@remote_hostname, @remote_port)
      if @tls
        require 'openssl'
        context = OpenSSL::SSL::SSLContext.new(@ssl_method)
        context.ca_file = @ca_file if @ca_file
        context.verify_mode = @verify_mode if @verify_mode
        @socket = OpenSSL::SSL::SSLSocket.new(sock, context)
        @socket.connect
        @socket.post_connection_check(@remote_hostname)
        raise "verification error" if @socket.verify_result != OpenSSL::X509::V_OK
      else
        @socket = sock
      end
    end

    def send_msg(payload)
      retry_limit = @retry_limit.to_i
      retry_count = 0
      sleep_time = 0.5

      begin
        @socket.puts(payload)
      rescue => e
        if retry_count < retry_limit
          $stderr.puts "#{e.class} error: retry after #{sleep_time} sec (#{retry_count} times)"
          sleep sleep_time
          retry_count += 1
          sleep_time *= 2
          connect
          retry
        else
          raise
        end
      end
    end
  end
end
