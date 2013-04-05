
module Puppet

  newtype(:broker) do
    @doc = "the custom type for qpidd creates the connection and qmf agent"

    newparam(:url) do
      defaultto 'localhost:5672'
      isnamevar
    end

    newparam(:service_name) do
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

    autorequire(:service) do
      [ "#{@provider.resource[:service_name]}" ]
    end

  end

end

