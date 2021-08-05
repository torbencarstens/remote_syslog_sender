
require 'remote_syslog_sender_ms/udp_sender'
require 'remote_syslog_sender_ms/tcp_sender'

module RemoteSyslogSender
  VERSION = '1.3.2'

  def self.new(remote_hostname, remote_port, options = {})
    protocol = options.delete(:protocol)
    if protocol && protocol.to_sym == :tcp
      TcpSender.new(remote_hostname, remote_port, options)
    else
      UdpSender.new(remote_hostname, remote_port, options)
    end
  end
end
