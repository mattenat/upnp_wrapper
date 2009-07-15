begin
  require 'UPnP'
  UPnP::UPnP
rescue Exception => e
  raise e, "Must have mupnp gem installed"
end

require 'upnp_wrapper/commands'

UpnpWrapper::Commands.startup

at_exit { UpnpWrapper::Commands.shutdown }
