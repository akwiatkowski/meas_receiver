require 'spec_helper'

describe MeasTypeReceiver do
  before :each do
    @i = IoServerFake.new
    @i.start_tcp_server

    MeasReceiver::CommProtocol.host = @i.host
    MeasReceiver::CommProtocol.port = @i.port

    @m = MeasTypeReceiver.new(
      {
        name: 'u_batt',
        unit: 'V',
        fetch_interval: 0.2,
        command: ['0'.chr],
        response_size: 2,
      }
    )
  end

  after :each do
    @i.stop_tcp_server
  end

  it "has array of measurements" do
    @m.meas_buffer.should be_kind_of(Array)
  end

  it "can start fetching measurements" do
    MeasReceiver::CommProtocol.should be_kind_of(Class)

    @m.start
    sleep 1
    puts @m.meas_buffer.to_yaml
  end

end
