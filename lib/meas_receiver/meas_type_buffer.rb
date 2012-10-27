require 'rufus/scheduler'

# All stuff related to data manipulation and storage

module MeasReceiver
  class MeasTypeBuffer
    def initialize(_meas_type)
      @meas_type = _meas_type
      @buffer = Array.new
      @size = 0
    end

    attr_accessor :buffer, :time_from, :time_to

    def add(v)
      @size += 1
      @buffer << v
      @time_from ||= Time.now
      @time_to = Time.now
    end

    def interval
      (@time_to - @time_from).to_f / @size.to_f
    end

    def [](i)
      {time: @time_to + interval, value: @buffer[0]}
    end

    def first
      self[0]
    end

    def last
      self[@size - 1]
    end

  end
end