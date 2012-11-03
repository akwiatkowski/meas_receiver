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
        value_deviation: 0.8,

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

  #it "kind of" do
  #  @b.should be_kind_of(MeasReceiver::MeasTypeBuffer)
  #end
  #
  #it "store measurements of long sine-like values" do
  #  count = 1000
  #  (0...count).each do |i|
  #    v = 512 + (Math.sin(i.to_f / 20.0) * 64.0).round
  #    @b.add(v)
  #  end
  #  @b.time_from = Time.now - count.to_f * 0.2
  #  @b.time_to = Time.now
  #
  #  # interval
  #  @b.interval.should be_within(0.01).of(0.2)
  #
  #  # times, first and last
  #  @b.first[:time].should be_within(0.5).of(@b.time_from)
  #  @b.last[:time].should be_within(0.5).of(@b.time_to)
  #
  #  # time, raw and value
  #  @b.first[:time].should be_kind_of(Time)
  #  @b.first[:raw].should be_kind_of(Fixnum)
  #  @b.first[:value].should be_kind_of(Float)
  #
  #  # perform storage
  #  @b.perform_storage
  #end
  #
  #it "store measurements of predefined values" do
  #  # 3 significant changes
  #  values = %w(512 513 515 515 514 515 515 516 517 518 550 550 550 555 550 545 510 512 522 515)
  #
  #  values.each do |v|
  #    @b.add(v.to_i)
  #  end
  #  @b.time_from = Time.now - values.count.to_f * 0.1
  #  @b.time_to = Time.now
  #
  #  @b.storage_buffer.size.should == 0
  #
  #  # perform storage
  #  @b.perform_storage
  #  @b.storage_buffer.size.should > 0
  #  @b.storage_buffer.size.should == 3
  #  @b.storage_buffer.each do |m|
  #    # proc execution testing
  #    m[:stored] == true
  #  end
  #
  #  # next run without new measurements -> buffer should be empty
  #  @b.perform_storage
  #  @b.storage_buffer.size.should == 0
  #end

  it "store measurements of predefined values with cleaning" do
    # 3 significant changes
    partial_values = %w(512 513 515 515 514 515 515 516 517 518 550 551 552 555 553 545 510 512 522 515)
    values = partial_values * 10
    # 9 last repeats will be cleaned

    values.each do |v|
      @b.add(v.to_i)
    end
    @b.time_from = Time.now - values.count.to_f * 0.1
    @b.time_to = Time.now

    @b.storage_buffer.size.should == 0

    _remove_index = partial_values.size * 9
    _a = @b[_remove_index + 10]
    @b.clean_up_to!(_remove_index)
    _b = @b[10]

    [:value, :raw].each do |k|
      _a[k].should == _b[k]
    end
    # there could be minimal time change
    _a[:time].should be_within(0.05).of(_b[:time])


    #puts _a.inspect, _b.inspect

    
  end

end
