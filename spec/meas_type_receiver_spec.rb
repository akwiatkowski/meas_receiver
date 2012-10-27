require 'spec_helper'

describe MeasTypeReceiver do
  before :each do
    meas_config = {
      name: 'u_batt',
      unit: 'V',
      fetch_interval: 0.2,
      command: ['0'],
      response_size: 2,
    }

    @default_value = 512
    @i ||= IoServerFake.new
    command_string = MeasReceiver::CommProtocol.prepare_command_string(meas_config[:command], meas_config[:response_size])
    value_string = MeasReceiver::CommProtocol.i_to_byte_array(@default_value, meas_config[:response_size])
    @i.add_response(command_string, value_string)
    
    @i.start_tcp_server
    MeasReceiver::CommProtocol.host = @i.host
    MeasReceiver::CommProtocol.port = @i.port

    @m = MeasTypeReceiver.new(meas_config)
  end

  after :each do
    @i.stop_tcp_server
  end

  it "has array of measurements" do
    @m.meas_buffer.should be_kind_of(Array)
  end

  it "fetch single measurements" do
    d = @m.fetch
    v = MeasReceiver::CommProtocol.byte_array_to_i(d)
    v.should == @default_value
  end

  #it "can start fetching measurements" do
  #  MeasReceiver::CommProtocol.should be_kind_of(Class)
  #
  #  @m.start
  #  sleep 1
  #  puts @m.meas_buffer.to_yaml
  #end

end
