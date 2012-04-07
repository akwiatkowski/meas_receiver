require 'singleton'
require 'yaml'

class IoServerFake
  #include Singleton

  PORT = 12345

  def initialize
    @port = PORT
    @responses = Hash.new
  end

  attr_reader :port, :responses

  def start_tcp_server
    @thread = Thread.new(@responses) { |_responses| start_tcp_server_in_thread(_responses) }
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

  # Add predefined response
  def add_response(k,v)
    @responses[k] = Array.new if @responses[k].nil?
    @responses[k] << v
  end

  # Get current predefined response
  def get_response(k)
    # TODO rewrite to Proc objects

    #puts @responses[k].to_yaml
    #puts @responses[k].class

    # should be already an Array
    @responses[k] = Array.new if @responses[k].nil?
    # if nothing is defined default response is char equal to 0
    @responses[k] << default_response if @responses[k].size == 0

    puts @responses[k].to_yaml
    #puts @responses[k].first

    current_response = @responses[k].first

    # always let last stay
    if @responses[k].size > 1
      @responses[k].shift
    end

    return current_response
  end

end