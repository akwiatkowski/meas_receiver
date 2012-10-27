require 'rufus/scheduler'

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

    @meas_buffer = Array.new
  end

  attr_reader :fetch_interval, :command, :response_size

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
    d = MeasReceiver::CommProtocol.create_and_send_command(@command, @response_size)
  end

  attr_reader :meas_buffer
end