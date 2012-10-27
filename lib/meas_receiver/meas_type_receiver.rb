class MeasTypeReceiver
  def initialize(_options)
    @options = _options
    @meas_buffer = Array.new
  end

  attr_reader :meas_buffer
end