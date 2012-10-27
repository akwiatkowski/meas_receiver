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

  it "simple stuff" do
    @b.should be_kind_of(MeasReceiver::MeasTypeBuffer)
  end
end
