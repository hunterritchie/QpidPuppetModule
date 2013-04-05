
module Puppet

  newtype(:binding) do
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

    autorequire(:broker) do
      [ "#{@provider.resource[:url]}" ]
    end

    autorequire(:exchange) do
      name_ary = value(:name).split(':')
      [ "#{name_ary[0]}" ]
    end

    autorequire(:queue) do
      name_ary = value(:name).split(':')
      [ "#{name_ary[1]}" ]
    end


  end

end

