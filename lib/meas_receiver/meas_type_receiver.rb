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
      @coefficients = _options[:coefficients]


      @comm_object = CommProtocol.new(@command, @response_size)
      @meas_buffer = MeasTypeBuffer.new(self)
    end

    attr_reader :fetch_interval, :command, :response_size, :coefficients

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
    end

    attr_reader :meas_buffer

  end
end