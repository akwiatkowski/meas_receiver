require 'spec_helper'

describe MeasReceiver::MeasTypeReceiver do
  context 'variable measurements' do
    before :each do
      values_count = 1000

      mc = {
        name: 'u_batt',
        unit: 'V',
        fetch_interval: 0.2,
        command: ['0'],
        response_size: 2,
      }

      @default_value = 512
      @i ||= IoServerFake.new
      (0...values_count).each do |i|
        _v = 512 + (Math.sin(i.to_f / 100.0) * 128.0).round
        @i.add_response(mc[:command], mc[:response_size], _v)
      end

      @i.start_tcp_server
      MeasReceiver::CommProtocol.host = @i.host
      MeasReceiver::CommProtocol.port = @i.port

      @m = MeasReceiver::MeasTypeReceiver.new(mc)
    end

    after :each do
      @i.stop_tcp_server
    end

    it "can start fetching measurements for one second" do
      MeasReceiver::CommProtocol.should be_kind_of(Class)
      @m.start
      sleep 1
      @m.stop

      puts @m.meas_buffer.to_yaml
      #@m.meas_buffer.size.should > 0
    end
    
  end
end
