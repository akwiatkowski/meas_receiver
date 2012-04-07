require 'spec_helper'
require 'io_server_fake'
require 'yaml'

describe IoServerFake do
  before :each do
    # responses has to be defined before starting server, fork, thread and other ruby stuff
  end

  after :each do
    @i.stop_tcp_server
  end

  it "should add simple predefined response" do
    @i = IoServerFake.new
    @i.start_tcp_server
    # some issues with tcp server
    sleep 0.005
  end


  #it "simple get" do
  #  command = MeasReceiver::CommProtocol.prepare_command_string(['0'], 2)
  #  res = MeasReceiver::CommProtocol.send_command(command, 'localhost', @i.port)
  #  res.should == @i.default_response
  #  puts res.inspect
  #end

  #2000.times do
  #  it "nothing" do
  #    # just checking before/after ;)
  #  end
  #end

  #it "should add predefined responses" do
  #  number =12345
  #  m_command = MeasReceiver::CommProtocol.prepare_command_string(['1'], 2)
  #  m_response = MeasReceiver::CommProtocol.i_to_byte_array(number, 2)
  #  @i.add_response(m_command, m_response)
  #  @i.responses[m_command].size.should == 1
  #  @i.responses[m_command].first.should == m_response
  #  #@i.get_response(m_command).should == m_response
  #  #@i.add_response(m_command, m_response)
  #  res = MeasReceiver::CommProtocol.send_command(m_command, 'localhost', @i.port)
  #  puts res.inspect
  #  #res.should == m_response
  #end

  #it "should add predefined responses" do
  #  m_command = MeasReceiver::CommProtocol.prepare_command_string(['1'], 2)
  #  m_response = MeasReceiver::CommProtocol.i_to_byte_array(123, 2)
  #  # add predefined response to '1' command
  #  # it should return value of 10 in 2 bytes string/byte array
  #  @i.add_response(m_command, m_response)
  #  # and receive this response
  #  res = MeasReceiver::CommProtocol.send_command(m_command, 'localhost', @i.port)
  #  #require 'yaml'
  #  #puts @i.responses.to_yaml
  #  res.should == m_response
  #end

end
