require 'rufus/scheduler'
require 'mean'

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
      { time: @time_from + interval * i, raw: @buffer[i], value: raw_to_value(@buffer[i]) }
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

    def averaged_raw(i, count = @storage[:avg_side_count].to_i)
      _from = i - count
      _to = i + count

      # not in range
      _from = 0 if _from < 0
      _to = @buffer.size - 1 if _to >= @buffer.size
      _a = @buffer[_from..._to]
      # puts "#{i}: #{_from}-#{_to}, size #{_to - _from}, mean #{_a.mean}, #{@buffer[_from]}, #{@buffer[_to]}"

      return _a.mean
    end

    # Get mean value within buffer
    def averaged_value(i, count = @storage[:avg_side_count].to_i)
      raw_to_value(averaged_raw(i, count))
    end

    def is_different(value_a, value_b)
      (value_a - value_b).abs > @storage[:value_deviation].to_f
    end

    # Executed by scheduler to store important values
    def perform_storage
      _range = storage_calculate_range
      _avg = storage_calculate_averaged(_range)
      _ids = storage_get_is_to_store(_avg, _range)

      #puts _ids.inspect

      _avg.each_with_index do |r,i|
        #puts r
      end

      return
      _first_value = averaged_value(_from)
      (_from.._to).each do |i|
        _a = averaged_value(i)
        #puts _first_value - _a
        #puts is_different(_a, _first_value)
      end

      # mark from where continue next time
      @storage_last_i = current_last_i

    end

    def storage_calculate_range
      # from where continue
      @storage_last_i = @storage_last_i.to_i
      _from = @storage_last_i
      # only check measurements up to
      _to = @buffer.size - 1
      return _from.._to
    end

    def storage_calculate_averaged(_range)
      _range.collect{|i| averaged_value(i)}
    end

    def storage_get_is_to_store(_values, _range)
      _array = Array.new
      _ref_value = _values.first
      (0...(_values.size)).each do |i|
        v = _values[i]
        if is_different(_ref_value, v)
          _array << i + _range.first
          _ref_value = v
        end 
      end
      return _array
    end

  end
end