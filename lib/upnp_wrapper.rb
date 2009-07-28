require 'upnp_wrapper/upnp_wrapper'

if UpnpWrapper::UpnpWrapper.valid_environment?
  require 'upnp'

  wrapper = UpnpWrapper::UpnpWrapper.new
  wrapper.startup

  at_exit { wrapper.shutdown }
end
