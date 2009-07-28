require 'upnp_wrapper/upnp_wrapper'

wrapper = UpnpWrapper::UpnpWrapper.new
wrapper.startup

at_exit { wrapper.shutdown }
