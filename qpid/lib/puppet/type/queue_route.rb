
module Puppet

  newtype(:queue_route) do
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

    newparam(:src_queue) do
    end

    newparam(:dst_exch) do
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
      [ "#{@provider.resource[:dst_exch]}" ]
    end

    autorequire(:queue) do
      [ "#{@provider.resource[:src_queue]}" ]
    end

  end

end

