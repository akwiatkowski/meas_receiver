require 'singleton'
require 'yaml'

class IoServerFake
  #include Singleton

  PORT = 12345

  def initialize
    @port = PORT
    @responses = Hash.new
  end

  def host
    'localhost'
  end

  attr_reader :port, :responses

  def start_tcp_server
    @thread = Thread.new(@responses) { |_responses| start_tcp_server_in_thread(_responses) }
    sleep 0.005
  end

  # Start server in current thread
  def start_tcp_server_in_thread(_responses)
    @responses = _responses
    @dts = TCPServer.new(port)

    loop do
      Thread.start(@dts.accept) do |s|
        begin
          command = s.gets
          #puts "4"*100, @responses.to_yaml
          response = get_response(command)
          #puts response.to_yaml
          s.write(response)
            #rescue => e
        ensure
          s.close
        end
      end
    end
  end

  # Kill server thread
  def stop_tcp_server
    begin
      @dts.close
    rescue
    end
    @thread.kill
  end

  # Default response when nothing is defined
  def default_response(size = 1)
    0.chr * size
  end

  # Get current predefined response
  def get_response(k)
    if @responses[k].nil?
      # not compatible with firmware
      current_response = default_response
    else
      response_obj = @responses[k]
      current_response = default_response

      # return first, and remove if there are more, if not return every time the last one
      if response_obj.kind_of?(Array)
        current_response = response_obj.first

        if response_obj.size > 1
          response_obj.shift
        end
      end

      if response_obj.kind_of?(Proc)
        current_response = response_obj.call
      end

    end
    return current_response
  end

end