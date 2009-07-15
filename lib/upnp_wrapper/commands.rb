module UpnpWrapper
  class Error < StandardError; end

  module Commands

    def self.startup
      begin
        logger.debug "Mapping router port #{config[:router_port]} to #{config[:local_port]}"

        client.addPortMapping(config[:router_port],
                              config[:local_port],
                              config[:protocol],
                              config[:description]) unless config.nil?
      rescue Exception => e
        raise UpnpWrapper::Error, e.to_s
      end
    end

    def self.shutdown
      logger.debug "Destroy mapping for router port #{config[:router_port]}"

      client.deletePortMapping(config[:router_port],
                               config[:protocol]) unless config.nil?
    end

  protected

    def self.client
      @@client ||= UPnP::UPnP.new
    end

    def self.logger
      RAILS_DEFAULT_LOGGER
    end

    CONFIG_DEFAULTS = {
      :router_port => 3000,
      :local_port => 3000,
      :protocol => UPnP::Protocol::TCP,
      :description => "Rails dev testing"
    }

    CONFIG_FILE = File.join(RAILS_ROOT, "config", "upnp.yml")

    def self.read_config
      begin
        new_configs =
          YAML.load_file(CONFIG_FILE)[RAILS_ENV]
        new_configs.symbolize_keys! if new_configs

        if new_configs[:protocol]
          new_configs[:protocol] =
            UPnP::Protocol.const_get(new_configs[:protocol].to_s.upcase)
        end
      rescue NameError
        logger.debug "Couldn't parse protocol.  Use `tcp' or `udp'.  Defaulting to `tcp'"
        new_configs.delete! :protocol if new_configs
      rescue Errno::ENOENT
        logger.debug "No file #{CONFIG_FILE} exists, using only defaults"
      end

      if new_configs
        CONFIG_DEFAULTS.merge(new_configs)
      else
        logger.debug "upnp_wrapper using default values instead of config/upnp.yml"
        CONFIG_DEFAULTS
      end
    end

    def self.config
      @@config ||= read_config
    end
  end  
end
