require 'rufus/scheduler'
require 'mean'

# All stuff related to data manipulation and storage

module MeasReceiver
  class MeasTypeBuffer
    def initialize(_meas_type)
      @meas_type = _meas_type
      @logger = @meas_type.logger
      @debug = @meas_type.debug
      @name = @meas_type.name

      @coefficients = _meas_type.coefficients
      @after_proc = _meas_type.after_proc
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
    attr_reader :storage_last_i, :storage_buffer, :size, :name

    # add raw value
    def add!(v)
      @mutex.synchronize do
        @size += 1
        @buffer << v
        @time_from ||= Time.now
        @time_to = Time.now

        @logger.debug("Added #{v.to_s.yellow} to buffer, size #{@size.to_s.blue}") if @debug
      end

      after_add
    end

    # Execute proc using last fetched measurement
    def after_add
      unless @after_proc.nil?
        @after_proc.call(self.last)
      end
    end

    def interval
      (@time_to - @time_from).to_f / @size.to_f
    end

    def [](i)
      return nil if i < 0 and i >= @size
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

    # Get measurement index for given time
    def index_by_time(_time)
      return nil if _time < @time_from or _time > @time_to
      return ((_time.to_f - @time_from.to_f)/interval.to_f).round
    end

    # Search measurement in buffer
    def at(_time)
      _i = index_by_time(_time)
      return nil if _i.nil?
      return self[_i]
    end

    # Average/mean raw within buffer
    def mean_raw(i, count = @storage[:avg_side_count].to_i)
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
    def perform_storage!
      @mutex.synchronize do
        @logger.debug("Performing storage for #{self.name.red}") if @debug

        _range = storage_calculate_range
        _avg = storage_calculate_averaged(_range)
        _indexes = storage_get_ranges_to_store(_avg, _range)
        _m = storage_measurements_to_store(_indexes, _range)
        @storage_buffer = _m

        # mark from where continue next time, it is r
        if _indexes.size > 0
          @storage_last_i = _indexes.last[1] + @storage_last_i.to_i
        end

        # call proc
        @logger.debug("Storage buffer size is #{@storage_buffer.size.to_s.cyan}") if @debug
        if @storage[:proc]
          @storage[:proc].call(@storage_buffer)
        end

        @logger.debug("Storage completed for #{self.name.red}") if @debug

        return @storage_buffer
      end
    end

    # Calculate range to storage algorithm
    def storage_calculate_range
      # from where continue
      _from = @storage_last_i
      # only check measurements up to
      _to = @buffer.size - 1

      @logger.debug("Range to store #{_from.to_s.magenta}..#{_to.to_s.magenta}") if @debug
      
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
      _r = ((_value_diff and _time_min) or _time_max)
      # puts "#{_r} - v: #{_value}, #{_ref_value}, #{_value_time}, #{_ref_value_time} -> #{_ref_value_nil} or (#{_value_diff} and #{_time_min}) or #{_time_max}"
      return _r
    end

    # Array of indexes measurements to store
    def storage_get_ranges_to_store(_values, _range)
      _array = Array.new

      _from = 0
      _ref_value = _values.first

      (0...(_values.size)).each do |_time|
        _value = _values[_time]

        if storage_should_store?(_value, _ref_value, _time, _from)
          _array << [_from, _time]

          _from = _time
          _ref_value = _value
        end
      end

      return _array
    end

    # Fill time_from using previous measurement
    def storage_measurements_to_store(_indexes, _range)
      # need to add @storage_last_i
      r = _indexes.collect { |is|
        _from = self[is[0] + @storage_last_i]
        _to = self[is[1] + @storage_last_i]

        _m = _from.clone
        _m[:time_from] = _m[:time]
        _m[:time_to] = _to[:time]
        _m.delete(:time)

        _m
      }
      return r
    end

    ### CLEANING

    # Clean measurements from buffer older than X seconds from last archived one
    def clean_up!(_interval = 10*60)
      _before_count = (_interval / self.interval).round
      clean_up_stored!(_before_count)
    end

    def clean_up_stored!(_before = 0)
      _i = @storage_last_i - _before
      _i = 0 if _i < 0
      clean_up_to!(_i)
    end

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