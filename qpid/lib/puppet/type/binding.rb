
module Puppet

  newtype(:binding) do
    @doc = "the custom type for qpidd creates the connection and qmf agent"

    newproperty(:ensure) do
      defaultto :insync
      newvalue :insync do
        @resource.provider.destroy
        @resource.provider.create
      end
      newvalue :outofsync

      def retrieve
        if @resource[:url].is_a?(Array)
          sync = :insync
          @resource[:url].each { |url| sync = :outofsync if :outofsync == retrieve_binding(url) }
          return sync
        else
          return retrieve_binding(@resource[:url])
        end
      end

      def retrieve_binding(url)
        broker = provider.setBroker(url)
        exchange, queue, key = @resource[:name].split(':')
        id = "org.apache.qpid.broker:exchange:#{exchange},org.apache.qpid.broker:queue:#{queue},#{key}"
        binding = broker[url].binding(id)

        return :outofsync if binding.nil?
        :insync
      end
    end


    newparam(:name) do
      isnamevar
    end

    newparam(:url) do
    end

    autorequire(:broker) do
      if @provider.resource[:url].is_a?(Array)
        @provider.resource[:url]
      else
        [ "#{@provider.resource[:url]}" ]
      end
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

