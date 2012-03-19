require 'spec_helper'
require 'io_server_fake'

describe IoServerFake do
  it "simple" do
    i = IoServerFake.instance
    Thread.new { i.start_tcp_server }
    #res = MeasReceiver::CommProtocol.prepare_command_string(['0'], 2)
    res = MeasReceiver::CommProtocol.send_command(['0'], 2, 'localhost', i.port)
    puts res.inspect
  end

end
