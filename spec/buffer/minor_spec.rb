require 'spec_helper'

describe MeasReceiver::MeasTypeBuffer do
  before :each do
    @fetch_interval = 1.0
    mc = {
      name: 'u_batt',
      unit: 'V',
      fetch_interval: @fetch_interval,
      command: ['0'],
      response_size: 2,

      coefficients: {
        linear: 0.0777126099706744868,
        offset: 0
      },

      storage: {
        proc: Proc.new { |d| puts d.inspect },
        min_time_interval: 0.1,
        max_time_interval: 3600,

        avg_side_count: 0, # X before, this, and X after
        value_deviation: 0.5,

        # for testing proc execution
        proc: Proc.new { |ms|
          ms.each do |m|
            m[:stored] = true
          end
        }
      }
    }

    @m = MeasReceiver::MeasTypeReceiver.new(mc)
    @b = @m.meas_buffer
  end

  it "multiple detailed store" do
    values = [500] * 10 + [550] * 10 + [500] * 10
    values.each do |v|
      @b.add!(v)
    end
    @b.time_from = Time.now - @b.buffer.size.to_f * @fetch_interval
    @b.time_to = Time.now

    # wtf ;)
    @b.at(@b.time_from)[:time].should be_within(0.01).of(@b.time_from)
    @b.at(@b.time_to)[:time].should be_within(0.01).of(@b.time_to)

  end

end
