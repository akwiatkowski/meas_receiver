require 'spec_helper'

describe MeasTypeReceiver do
  before :each do
    @m = MeasTypeReceiver.new(
      {
        name: 'u_batt',
        unit: 'V'
      }
    )
  end

  it "has array of measurements" do
    @m.meas_buffer.should be_kind_of(Array)
  end
end
