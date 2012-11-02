require 'rufus/scheduler'

# All stuff related to data manipulation and storage

module MeasReceiver
  class MeasTypeBuffer
    def initialize(_meas_type)
      @meas_type = _meas_type

      @coefficients = _meas_type.coefficients
      @storage = _meas_type.storage
      # index from which start storage algorithm
      @storage_last_i = nil

      @buffer = Array.new
      @size = 0
    end

    attr_accessor :buffer, :time_from, :time_to, :coefficients, :storage

    attr_reader :storage_last_i

    # add raw value
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
      {time: @time_from + interval * i, raw: @buffer[i], value: raw_to_value(@buffer[i])}
    end

    def raw_to_value(raw)
      _r = raw.to_f * @coefficients[:linear].to_f + @coefficients[:offset]
      if @coefficients[:proc]
        _r = @coefficients[:proc].call(_r)
      end
      return _r
    end

    def first
      self[0]
    end

    def last
      self[@size - 1]
    end

    def averaged_value(i, count = @storage[:avg_side_count].to_i)
      _from = i - count
      _to = i + count

      puts "#{i}: #{_from}-#{_to}, size #{_to - _from}"

      # not in range
      _from = 0 if _from < 0
      _to = @buffer.size - 1 if _to >= @buffer.size

      return @buffer[_from, _to].size
    end

    # Executed by scheduler to store important values
    def perform_storage
      @storage_last_i = @storage_last_i.to_i
      # only check measurements up to
      current_last_i = @buffer.size - 1
      _to = current_last_i
      # next time run it from last stored measurement
      continue_from = @storage_last_i
      _from = @storage_last_i

      (_from.._to).each do |i|
        _a = averaged_value(i)
      end
      


      # mark from where continue
      @storage_last_i = current_last_i
    end

  end
end