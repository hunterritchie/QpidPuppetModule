
module Puppet

  newtype(:link) do
    @doc = "the custom type for qpidd creates the connection and qmf agent"
    ensurable do
      defaultvalues
      defaultto :present
    end

    newparam(:name) do
      isnamevar
    end

    newparam(:url) do
    end

    newparam(:remote_host) do
    end

    newparam(:remote_port) do
    end

    newparam(:transport) do
      defaultto 'tcp'
    end

    newparam(:durable) do
    end

    newparam(:auth) do
    end

    newparam(:username) do
    end

    newparam(:password) do
    end

    autorequire(:broker) do
      [ "#{@provider.resource[:url]}" ]
    end

  end

end

