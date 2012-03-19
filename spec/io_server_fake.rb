require 'singleton'

class IoServerFake
  include Singleton

  PORT = 12345

  def initialize
    @port = PORT
  end

  attr_reader :port

  def start_tcp_server
    dts = TCPServer.new(port)

    loop do
      Thread.start(dts.accept) do |s|
        begin
          puts s.class
          command = s.gets
          response = '01' # TODO
          s.write(response)
        #rescue => e
        ensure
          s.close
        end
      end
    end
  end

  def receive_command

  end

  def send_command

  end


end