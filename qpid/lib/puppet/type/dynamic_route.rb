
module Puppet

  newtype(:exchange_route) do
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

    newparam(:link) do
    end

    newparam(:exchange) do
    end

    newparam(:sync) do
    end

    autorequire(:broker) do
      [ "#{@provider.resource[:url]}" ]
    end

    autorequire(:link) do
      [ "#{@provider.resource[:link]}" ]
    end

    autorequire(:exchange) do
      [ "#{@provider.resource[:exchange]}" ]
    end

  end

end

