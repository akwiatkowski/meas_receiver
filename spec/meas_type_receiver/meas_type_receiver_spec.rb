require 'spec_helper'

describe MeasReceiver::MeasTypeReceiver do
  context 'some basic stuff' do
    before :each do
      mc = {
        name: 'u_batt',
        unit: 'V',
        fetch_interval: 0.2,
        command: ['0'],
        response_size: 2,
      }

      @default_value = 512
      @i ||= IoServerFake.new
      @i.add_response(mc[:command], mc[:response_size], @default_value)

      @i.start_tcp_server
      MeasReceiver::CommProtocol.host = @i.host
      MeasReceiver::CommProtocol.port = @i.port

      @m = MeasReceiver::MeasTypeReceiver.new(mc)
    end

    after :each do
      @i.stop_tcp_server
    end

    it "has array of measurements" do
      @m.meas_buffer.buffer.should be_kind_of(Array)
    end

    it "fetch single measurements" do
      @m.fetch
      d = @m.last[:raw]
      d.should be_kind_of Fixnum
      d.should == @default_value
    end
  end
end
