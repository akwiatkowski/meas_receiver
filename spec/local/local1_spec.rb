require 'spec_helper'
require 'logger'

describe MeasReceiver::MeasTypeBuffer do
  before :each do
    MeasReceiver::CommProtocol.host = '192.168.0.13'
    MeasReceiver::CommProtocol.port = '2002'

    @fetch_interval = 0.2
    mc = {
      name: 'batt_u',
      unit: 'V',
      storage: {
        proc: Proc.new { |d| puts "store - #{d.inspect}" },
        min_time_interval: 0.5,
        max_time_interval: 3600,

        avg_side_count: 10,
        value_deviation: 1.0,

        store_interval: 5
      },

      command: ['3'],
      response_size: 2,
      coefficients: {
        linear: 0.0777126099706744868,
        offset: 0
      },

      after_proc:  Proc.new { |d| puts "fetch - #{d.inspect}" },
    }

    @m = MeasReceiver::MeasTypeReceiver.new(mc)
  end

  it "local test (single fetch)" do
    @m.fetch
    puts @m.last.inspect
  end

  it "local test (start)" do
    @m.start
    sleep 20
  end

end


