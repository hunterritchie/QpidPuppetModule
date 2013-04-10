require File.dirname(__FILE__) + '/../common/functions'

module Puppet

  newtype(:queue_route) do
     @doc = "Creates a queue route between source queue and destination exchange, using the specified link."


    newproperty(:ensure) do
      defaultto :insync

      newvalue :insync do
        @resource.provider.destroy
        @resource.provider.create
      end

      newvalue :outofsync

      include Retrieve

      def _retrieve(url)
        broker = Qpid::setBroker(url)
        broker[url].bridges.each do |bridge|
          if @resource[:name] == bridge['name']
            return :outofsync unless bridge['dest'] == @resource[:dst_exch]
            return :outofsync unless bridge['src'] == @resource[:src_queue]
            return :outofsync unless bridge['sync'].to_s == @resource[:sync].to_s
            return :outofsync unless bridge['dynamic'] == false
            return :outofsync unless bridge['key'] == ''
            return :outofsync unless bridge['linkRef'] == @resource[:link]
            return :insync
          end
        end
        return :outofsync
      end
    end

    newparam(:name) do
      desc "The queue route name."
      isnamevar
    end

    newparam(:url) do
      desc "The url of the qpidd broker, in the format of <ipaddr>:<port> or <hostname>:<port>. An array of urls may be provided."
      defaultto 'localhost:5672'
    end

    newparam(:link) do
      desc "The name of the link to use."
    end

    newparam(:src_queue) do
      desc "The name of the source queue to use."
    end

    newparam(:dst_exch) do
      desc "The name of the destination exchange to use."
    end

    newparam(:sync) do
      desc "Acknowledge transfers over the bridge in batches of N."
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

