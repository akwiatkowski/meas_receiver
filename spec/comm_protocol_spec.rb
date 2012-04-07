require 'spec_helper'
require 'io_server_fake'

describe MeasReceiver::CommProtocol do
  it "should convert byte array to number" do
    ba = 0.chr + 1.chr
    res = MeasReceiver::CommProtocol.byte_array_to_i(ba)
    res.should == 1
  end

  it "should convert byte array to number (2)" do
    ba = 1.chr + 2.chr
    res = MeasReceiver::CommProtocol.byte_array_to_i(ba)
    res.should == 256 + 2
  end

  it "should convert byte array to number (3)" do
    ba = 1.chr + 2.chr + 3.chr + 4.chr
    res = MeasReceiver::CommProtocol.byte_array_to_i(ba)
    res.should == 256**3 + 2 * 256**2 + 3 * 256 + 4
  end

  it "should convert number to byte array without adding zeros at front" do
    ba = 1.chr
    res = MeasReceiver::CommProtocol.i_to_byte_array(1)
    res.should == ba
  end

  it "should convert number to byte array without adding zeros at front (2)" do
    ba = 1.chr + 2.chr + 3.chr + 4.chr
    res = MeasReceiver::CommProtocol.i_to_byte_array(256**3 + 2 * 256**2 + 3 * 256 + 4)
    res.should == ba
  end

  it "should convert number to byte array with adding zeros at front" do
    ba = 0.chr * 4 + 1.chr
    res = MeasReceiver::CommProtocol.i_to_byte_array(1, 5)
    res.should == ba
  end

  it "should convert number to byte array with adding zeros at front (2)" do
    ba = 0.chr * 6 + 1.chr + 2.chr + 3.chr + 4.chr
    res = MeasReceiver::CommProtocol.i_to_byte_array(256**3 + 2 * 256**2 + 3 * 256 + 4, 10)
    res.should == ba
  end




end
