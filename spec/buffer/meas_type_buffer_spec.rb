require 'spec_helper'

describe MeasReceiver::MeasTypeBuffer do
  before :each do
    mc = {
      name: 'u_batt',
      unit: 'V',
      fetch_interval: 0.2,
      command: ['0'],
      response_size: 2,

      coefficients: {
        linear: 0.0777126099706744868,
        offset: 0
      },

      storage: {
        proc: Proc.new { |d| puts d.inspect },
        min_time_interval: 0.5,
        max_time_interval: 3600,

        avg_side_count: 4, # 3 before, this, and 3 after
        value_deviation: 0.8
      }

    }

    # TODO: storage, clean

    @m = MeasReceiver::MeasTypeReceiver.new(mc)
    @b = @m.meas_buffer
  end

  it "kind of" do
    @b.should be_kind_of(MeasReceiver::MeasTypeBuffer)
  end

  it "store values" do
    count = 1000
    (0...count).each do |i|
      v = 512 + (Math.sin(i.to_f / 20.0) * 64.0).round
      @b.add(v)
    end
    @b.time_from = Time.now - count.to_f * 0.2
    @b.time_to = Time.now

    # interval
    @b.interval.should be_within(0.01).of(0.2)

    # times, first and last
    @b.first[:time].should be_within(0.5).of(@b.time_from)
    @b.last[:time].should be_within(0.5).of(@b.time_to)

    # time, raw and value
    @b.first[:time].should be_kind_of(Time)
    @b.first[:raw].should be_kind_of(Fixnum)
    @b.first[:value].should be_kind_of(Float)

    # perform storage
    @b.perform_storage
    puts @b.storage_last_i

  end
end
