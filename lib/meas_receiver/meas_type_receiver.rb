require 'logger'
require 'colorize'
require 'rufus/scheduler'
require 'meas_receiver/meas_type_buffer'

module MeasReceiver
  class MeasTypeReceiver

    SCH_MIN_INTERVAL = 0.05
    DEFAULT_FETCH_INTERVAL = 0.5
    MIN_FETCH_INTERVAL = 0.1

    # TODO convert all keys to Symbols

    def initialize(_options)
      @options = _options

      @options[:logger] ||= Hash.new
      @options[:logger][:output] ||= STDOUT
      @options[:logger][:level] ||= Logger::INFO
      @logger = Logger.new(@options[:logger][:output])
      @logger.level = @options[:logger][:level]
      @debug = (@options[:logger][:level] == Logger::DEBUG)

      @fetch_interval = _options[:fetch_interval] || DEFAULT_FETCH_INTERVAL
      @fetch_interval = MIN_FETCH_INTERVAL if @fetch_interval < MIN_FETCH_INTERVAL

      @name = @options[:name]
      @command = @options[:command]
      @response_size = @options[:response_size]
      @coefficients = @options[:coefficients] || Hash.new
      @coefficients[:linear] ||= 1.0
      @coefficients[:offset] ||= 0.0
      @after_proc = @options[:after_proc]
      @storage = @options[:storage] || Hash.new
      @storage[:min_time_interval] ||= @fetch_interval
      @storage[:min_unit_interval] = (@storage[:min_time_interval] / @fetch_interval).floor
      @storage[:max_time_interval] ||= 3600
      @storage[:max_unit_interval] = (@storage[:max_time_interval] / @fetch_interval).floor
      @storage[:store_interval] ||= 10*60 #2*3600

      @comm_object = CommProtocol.new(@command, @response_size)
      @meas_buffer = MeasTypeBuffer.new(self)
    end

    attr_reader :fetch_interval, :command, :response_size, :coefficients, :storage, :name, :logger, :debug, :after_proc

    def start
      @logger.debug("MeasReceiver started for #{self.name.red}") if @debug

      @scheduler = Rufus::Scheduler.start_new(frequency: SCH_MIN_INTERVAL)
      @scheduler.every "#{@fetch_interval}s" do
        fetch
      end

      @scheduler.every "#{@storage[:store_interval]}s" do
        store
      end
    end

    def stop
      @scheduler.stop
      @logger.debug("MeasReceiver stopped for #{self.name.red}") if @debug
    end

    def fetch
      v = @comm_object.g
      @meas_buffer.add!(v)

      @logger.debug("Fetched #{self.name.red} = #{v.to_s.yellow}") if @debug

      return v
    end

    def store
      @meas_buffer.perform_storage!
    end

    def clean
      @meas_buffer.clean_up!
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