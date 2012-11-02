require 'rufus/scheduler'
require 'meas_receiver/meas_type_buffer'

module MeasReceiver
  class MeasTypeReceiver

    SCH_MIN_INTERVAL = 0.05
    DEFAULT_FETCH_INTERVAL = 0.5
    MIN_FETCH_INTERVAL = 0.1

    def initialize(_options)
      @options = _options

      @fetch_interval = _options[:fetch_interval] || DEFAULT_FETCH_INTERVAL
      @fetch_interval = MIN_FETCH_INTERVAL if @fetch_interval < MIN_FETCH_INTERVAL

      @command = _options[:command]
      @response_size = _options[:response_size]
      @coefficients = _options[:coefficients] || Hash.new
      @coefficients[:linear] ||= 1.0
      @coefficients[:offset] ||= 0.0
      @storage = _options[:storage]

      @comm_object = CommProtocol.new(@command, @response_size)
      @meas_buffer = MeasTypeBuffer.new(self)
    end

    attr_reader :fetch_interval, :command, :response_size, :coefficients, :storage

    def start
      @scheduler = Rufus::Scheduler.start_new(frequency: SCH_MIN_INTERVAL)
      @scheduler.every "#{@fetch_interval}s" do
        fetch
      end
    end

    def stop
      @scheduler.stop
    end

    def fetch
      v = @comm_object.g
      @meas_buffer.add(v)
      return v
    end

    attr_reader :meas_buffer

    def [](i)
      @meas_buffer[i]
    end

    def first
      @meas_buffer.first
    end

    def last
      @meas_buffer.last
    end

  end
end