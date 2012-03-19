require 'socket'

module MeasReceiver
  class CommProtocol

    def self.send_command(command_array, response_size, hostname, port)
      str = prepare_command_string(command_array, response_size)
      s = TCPSocket.open(hostname, port)
      s.puts(str)
      data = s.gets
      s.close

      return data
    end

    def self.prepare_command_string(command_array, response_size)
      command_array.size.chr + response_size.chr + command_array.collect { |c|
        if c.kind_of? Fixnum
          c.chr
        else
          c.to_s
        end
      }.join('')
    end

  end
end