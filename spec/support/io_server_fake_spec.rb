require 'spec_helper'
require 'support/io_server_fake'
require 'yaml'

describe IoServerFake do
  it "should has default response" do
    @i = IoServerFake.new
    @i.start_tcp_server
    @i.stop_tcp_server
  end

  # this is not compatible with current version of HomeIO firmware
  it "should get default response" do
    @i = IoServerFake.new
    @i.start_tcp_server

    m_command = MeasReceiver::CommProtocol.prepare_command_string(['1'], 1)
    m_response = MeasReceiver::CommProtocol.i_to_byte_array(0, 1)
    res = MeasReceiver::CommProtocol.send_command(m_command, 'localhost', @i.port)
    res.should == m_response

    @i.stop_tcp_server
  end

  it "should set response" do
    @i = IoServerFake.new
    @i.responses.should be_kind_of(Hash)
    command = 0.chr

    # Array
    a = [1, 2, 3, 4]
    @i.responses[command] = a
    @i.responses[command].should == a

    @i.get_response(command).should == 1
    @i.get_response(command).should == 2
    @i.get_response(command).should == 3
    10.times do
      @i.get_response(command).should == 4
    end

    # Proc
    a = Proc.new{ 2 }
    @i.responses[command] = a
    @i.responses[command].should == a
    10.times do
      @i.get_response(command).should == 2
    end


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
