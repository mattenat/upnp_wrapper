begin
  require 'UPnP'
  UPnP::UPnP
rescue Exception => e
  raise e, "Must have mupnp gem installed"
end

require 'upnp_wrapper/upnp_wrapper'

wrapper = UpnpWrapper::UpnpWrapper.new
wrapper.startup

at_exit { wrapper.shutdown }
