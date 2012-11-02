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

    # Average/mean raw within buffer
    def mean_raw(i, count = @storage[:avg_side_count])
      _from = i - count
      _to = i + count

      # not in range
      _from = 0 if _from < 0
      _to = @buffer.size - 1 if _to >= @buffer.size
      _a = @buffer[_from..._to]

      return _a.mean
    end

    # Get mean value within buffer
    def mean_value(i, count = @storage[:avg_side_count])
      raw_to_value(mean_raw(i, count))
    end

    # Executed by scheduler to store important values
    def perform_storage
      _range = storage_calculate_range
      _avg = storage_calculate_averaged(_range)
      _indexes = storage_get_is_to_store(_avg, _range)
      _m = storage_measurements_to_store(_indexes)

      puts _m.inspect

      # mark from where continue next time
      @storage_last_i = current_last_i
    end

    # Calculate range to storage algorithm
    def storage_calculate_range
      # from where continue
      @storage_last_i = @storage_last_i.to_i
      _from = @storage_last_i
      # only check measurements up to
      _to = @buffer.size - 1
      return _from.._to
    end

    # Prepare averaged values
    def storage_calculate_averaged(_range)
      _range.collect{|i| mean_value(i)}
    end

    # Check value deviation
    def storage_should_store_value?(value_a, value_b)
      (value_a - value_b).abs > @storage[:value_deviation].to_f
    end

    # Store if value if different more than X and is newer tan Y, force when it is newer than Z
    def storage_should_store?(_value, _ref_value, _value_time, _ref_value_time)
      (storage_should_store_value?(_ref_value, _value) and (_value_time - _ref_value_time) > @storage[:min_unit_interval]) or (_value_time - _ref_value_time) > @storage[:max_unit_interval]
    end

    # Array of indexes measurements to store
    def storage_get_is_to_store(_values, _range)
      _array = Array.new
      _rel_time = _range.first
      _ref_value = _values.first
      _ref_value_rel_time = 0

      (0...(_values.size)).each do |_value_rel_time|
        _value = _values[_value_rel_time]
        if storage_should_store?(_value, _ref_value, _value_rel_time, _ref_value_rel_time)
          _array << _value_rel_time + _rel_time
          _ref_value = _value
          _ref_value_rel_time = _value_rel_time
        end 
      end
      return _array
    end

    def storage_measurements_to_store(_indexes)
      _m = _indexes.collect{|i| self[i]}

      return _m
    end

  end
end