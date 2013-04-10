
module Puppet

  newtype(:broker) do
    @doc = "Creates a qpidd broker to ensure dependencies are met."

    newparam(:url) do
      desc "The url of the qpidd broker, in the format of <ipaddr>:<port> or <hostname>:<port>."
      defaultto 'localhost:5672'
      isnamevar
    end

    newparam(:service_name) do
      desc "The name of the broker as a service, maps the init.d, qpidd.conf, aand qpidd.acl files."
    end


    autorequire(:file) do
      [ "/etc/init.d/#{@provider.resource[:service_name]}" ]
    end

    autorequire(:file) do
      [ "/etc/qpidd/#{@provider.resource[:service_name]}" ]
    end

    autorequire(:file) do
      [ "/etc/qpidd/#{@provider.resource[:service_name]}/qpidd.conf" ]
    end

    autorequire(:file) do
      [ "/etc/qpidd/#{@provider.resource[:service_name]}/qpidd.acl" ]
    end

    autorequire(:service) do
      [ "#{@provider.resource[:service_name]}" ]
    end

  end

end

