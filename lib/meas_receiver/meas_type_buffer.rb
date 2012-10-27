require 'rufus/scheduler'

# All stuff related to data manipulation and storage

module MeasReceiver
  class MeasTypeBuffer
    def initialize(_meas_type)
      @meas_type = _meas_type
      @buffer = Array.new
    end

    def add(v)
      @buffer << v
      @time_from ||= Time.now
      @time_to = Time.now
    end

  end
end