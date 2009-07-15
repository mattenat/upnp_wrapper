class UpnpWrapperGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.template "upnp.yml", "config/upnp.yml"
    end
  end
end
