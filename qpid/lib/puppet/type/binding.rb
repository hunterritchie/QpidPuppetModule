
module Puppet

  newtype(:binding) do
    @doc = "the custom type for qpidd creates the connection and qmf agent"
    ensurable do
      defaultvalues
      defaultto :present
    end

    newparam(:name) do
      isnamevar
      #name_ary = value(:name).split(':')
      #value(:exchange) = name_ary[0]
      #value(:queue) = name_ary[1]
      #value(:key) = name_ary[2] || ''
    end

    newparam(:url) do
    end

    #newparam(:exchange) do
    #end
#
    #newparam(:queue) do
    #end
#
    #newparam(:key) do
    #end

    autorequire(:service) do
      [ "qpidd" ]
      #[ "qpidd_#{namevar}" ]
    end

    autorequire(:file) do
      [ "/etc/init.d/qpidd" ]
      #[ "/etc/init.d/qpidd_#{namevar}" ]
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

