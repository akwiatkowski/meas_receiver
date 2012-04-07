require 'socket'

module MeasReceiver
  class CommProtocol

    # Create String command to IoServer and send it
    def self.create_send_command(command_array, response_size, hostname, port)
      return send_command(str, hostname, port)
    end

    # Send command to IoServer and send it
    def self.send_command(command_byte_array, hostname, port)
      s = TCPSocket.open(hostname, port)
      s.puts(command_byte_array)
      data = s.gets
      s.close

      return data
    end

    # Create command string to IoServer
    # command_array can be Array, String or even Fixnum
    def self.prepare_command_string(command_array, response_size)
      if command_array.kind_of?(Array)
        command_byte_array = command_array
      elsif command_array.kind_of?(String)
        command_byte_array = command_array.split(//)
      elsif command_array.kind_of?(Fixnum)
        command_byte_array = [ command_array.chr ]
      else
        raise ArgumentError
      end

      command_byte_array.size.chr + response_size.chr + command_byte_array.collect { |c|
        if c.kind_of? Fixnum
          c.chr
        else
          c.to_s
        end
      }.join('')
    end

    # Convert string/byte array to number
    def self.byte_array_to_i(ba)
      number = 0
      ba.each_byte do |b|
        number *= 256
        number += b
      end
      number
    end

    # Convert number to string/byte
    def self.i_to_byte_array(number, zero_fill = 0)
      ba = ''
      n = number.to_i
      while n > 256
        r = n % 256
        ba += r.chr
        n = (n - r) / 256
      end
      ba += n.chr

      # fill with zeroes
      if ba.size < zero_fill
        fill_count = zero_fill - ba.size
        ba += 0.chr * fill_count
      end
      # reverse magic

      ba.reverse
    end

  end
end