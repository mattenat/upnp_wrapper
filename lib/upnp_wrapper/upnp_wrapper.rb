module UpnpWrapper
  class Error < StandardError; end

  class UpnpWrapper
    CONFIG_FILE = File.join(RAILS_ROOT, "config", "upnp.yml")
    DEFAULT_PROTOCOL = UPnP::Protocol::TCP

    attr_reader :router_port, :local_port, :protocol, :description, :logger

    def initialize(config_file = CONFIG_FILE, logger = RAILS_DEFAULT_LOGGER)
      # defaults
      @started = false
      @logger = logger
      @router_port = 80
      @local_port = 3000
      @protocol = DEFAULT_PROTOCOL
      @description = "Rails UPnP::Wrapper"
      @active = false

      read_config(config_file)
    end

    def started?
      @started
    end

    def active?
      @active
    end

    def startup
      if valid_environment? && !started?
        begin
          logger.debug "Mapping router port #{router_port} to #{local_port}"

          client.addPortMapping(router_port, local_port, protocol, description)
          @started = true
        rescue Exception => e
          raise UpnpWrapper::Error, e.to_s
        end
      end
    end

    def shutdown
      client.deletePortMapping(router_port, protocol) if started?
    end

    def valid_environment?
      # don't open a port in script/console mode
      @valid ||= active? && !Object.const_defined?(:IRB)
    end

  protected

    def read_config(file)
      begin
        from_file = YAML.load_file(CONFIG_FILE)[RAILS_ENV]
        from_file.symbolize_keys! if from_file

        [:router_port, :local_port, :description, :active].each do |prop|
          # override the defaults
          instance_variable_set("@#{prop}".to_sym,
                                from_file[prop]) if from_file[prop]
        end

        if from_file[:protocol]
          @protocol =
            UPnP::Protocol.const_get(from_file[:protocol].to_s.upcase)
        end
      rescue NameError
        logger.debug "Couldn't parse protocol.  Use `tcp' or `udp'.  Defaulting to `tcp'"
        @protocol = DEFAULT_PROTOCOL
      rescue Errno::ENOENT
        logger.debug "No file #{CONFIG_FILE} exists, using only defaults"
      end
    end

    def client
      @client ||= UPnP::UPnP.new
    end

  end
end
