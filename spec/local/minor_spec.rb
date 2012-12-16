require 'spec_helper'
require 'logger'

describe MeasReceiver::MeasTypeBuffer do
  before :each do
    MeasReceiver::CommProtocol.host = '192.168.0.7'
    MeasReceiver::CommProtocol.port = '2002'

    @fetch_interval = 0.2
    mc = {
      name: 'u_batt',
      unit: 'V',
      fetch_interval: @fetch_interval,
      command: ['4'],
      response_size: 2,

      coefficients: {
        linear: 0.0777126099706744868,
        offset: 0
      },

      storage: {
        proc: Proc.new { |d| puts d.inspect },
        min_time_interval: 0.1,
        max_time_interval: 2.0,

        avg_side_count: 0, # X before, this, and X after
        value_deviation: 0.1,

        store_interval: 1.0
      },

      logger: {
        level: Logger::DEBUG,
        output: STDOUT
      }
    }

    @m = MeasReceiver::MeasTypeReceiver.new(mc)
  end

  #it "local test (single fetch)" do
  #  @m.fetch
  #  puts @m.last.inspect
  #end

  it "local test (start)" do
    @m.start
    sleep 20
  end

end
