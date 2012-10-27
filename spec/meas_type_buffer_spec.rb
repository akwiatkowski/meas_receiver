require 'spec_helper'

describe MeasReceiver::MeasTypeBuffer do
  before :each do
    mc = {
      name: 'u_batt',
      unit: 'V',
      fetch_interval: 0.2,
      command: ['0'],
      response_size: 2,
    }

    @m = MeasReceiver::MeasTypeReceiver.new(mc)
    @b = @m.meas_buffer
  end

  it "kind of" do
    @b.should be_kind_of(MeasReceiver::MeasTypeBuffer)
  end

  it "store values" do
    count = 1000
    (0...count).each do |i|
      v = 38.0 + Math.sin(i.to_f / 20.0) * 5.0
      @b.add(v)
    end
    @b.time_from = Time.now - count.to_f * 0.2
    @b.time_to = Time.now

    # interval
    @b.interval.should be_within(0.01).of(0.2)

    # times, first and last
    @b.first[:time].should be_within(0.5).of(@b.time_from)
    @b.last[:time].should be_within(0.5).of(@b.time_to)
    @b.buffer[0][:time].should be_within(0.5).of(@b.time_from)
    @b.buffer[@b.buffer.size - 1][:time].should be_within(0.5).of(@b.time_to)

    @b.first[:time]
    @b.last[:value]

    # first
    puts @b.first.inspect

  end
end
