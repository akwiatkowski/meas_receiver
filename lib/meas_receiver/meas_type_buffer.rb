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
      @storage_last_i = 0
      # last storage buffer
      @storage_buffer = Array.new

      @buffer = Array.new
      @size = 0

      @mutex = Mutex.new
    end

    attr_accessor :buffer, :time_from, :time_to, :coefficients, :storage

    attr_reader :storage_last_i, :storage_buffer, :size

    # add raw value
    def add(v)
      @mutex.synchronize do
        @size += 1
        @buffer << v
        @time_from ||= Time.now
        @time_to = Time.now
      end
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
      return @buffer[i] if count == 0

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

    ### STORAGE

    # Executed by scheduler to store important values
    def perform_storage
      _range = storage_calculate_range
      _avg = storage_calculate_averaged(_range)
      _indexes = storage_get_is_to_store(_avg, _range)
      _m = storage_measurements_to_store(_indexes, _range)
      @storage_buffer = _m

      # mark from where continue next time
      @storage_last_i = _indexes.last

      # call proc
      if @storage[:proc]
        @storage[:proc].call(@storage_buffer)
      end

      return @storage_buffer
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
      _range.collect { |i| mean_value(i) }
    end

    # Check value deviation
    def storage_should_store_value?(value_a, value_b)
      return true if value_a.nil? or value_b.nil?
      (value_a - value_b).abs > @storage[:value_deviation].to_f
    end

    # Store if value if different more than X and is newer tan Y, force when it is newer than Z
    def storage_should_store?(_value, _ref_value, _value_time, _ref_value_time)
      _ref_value_nil = _ref_value.nil?
      _value_diff = storage_should_store_value?(_ref_value, _value)
      _time_min = (_value_time - _ref_value_time).abs > @storage[:min_unit_interval]
      _time_max = (_value_time - _ref_value_time) > @storage[:max_unit_interval]
      _r = ( _ref_value_nil or (_value_diff and _time_min) or _time_max )
      # puts "#{_r} - v: #{_value}, #{_ref_value}, #{_value_time}, #{_ref_value_time} -> #{_ref_value_nil} or (#{_value_diff} and #{_time_min}) or #{_time_max}"
      return _r
    end

    # Array of indexes measurements to store
    def storage_get_is_to_store(_values, _range)
      _array = Array.new
      _rel_time = _range.first
      _ref_value = nil
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

    # Fill time_from using previous measurement
    def storage_measurements_to_store(_indexes, _range)
      _t = self[_range.first]
      _m = _indexes.collect { |i| self[i] }

      _m.each do |m|
        m[:time_from] = _t[:time]
        m[:time_to] = m[:time]

        _t = m
      end

      _m.each do |m|
        m.delete(:time)
      end

      return _m
    end

    ### CLEANING

    # Remove everything before "i"
    def clean_up_to!(i)
      @mutex.synchronize do
        _interval = self.interval
        @buffer = @buffer[i..-1]
        @size -= i
        @storage_last_i -= i
        @time_from += _interval * i
      end
    end

  end
end