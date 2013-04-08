
module Puppet

  newtype(:exchange) do
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
          @resource[:url].each { |url| sync = :outofsync if :outofsync == retrieve_exchange(url) }
          return sync
        else
          return retrieve_exchange(@resource[:url])
        end
      end

      def retrieve_exchange(url)
        broker = provider.setBroker(url)
        exchange = broker[url].exchange(@resource[:name])

        return :outofsync if exchange.nil?
        return :outofsync unless exchange.content['_values']['type'] == @resource[:type]

        unless @resource[:alt_exch].nil?  and exchange.content['_values']['altExchange'].nil?
          fq_resource_altexch = "org.apache.qpid.broker:exchange:#{@resource[:alt_exch]}"
          fq_qpid_altexch = exchange.content['_values']['altExchange']['_object_name'] unless exchange.content['_values']['altExchange'].nil?
          return :outofsync unless fq_resource_altexch == fq_qpid_altexch
        end
      
        durable = @resource[:durable].nil? ? false : @resource[:durable]
        return :outofsync unless exchange.content['_values']['durable'] == durable

        return :outofsync unless exchange.content['_values']['arguments']['replicate'] == @resource[:replicate]
        return :outofsync unless exchange.content['_values']['arguments']['qpid.msg_sequence'] == @resource[:msg_sequence]
        return :outofsync unless exchange.content['_values']['arguments']['qpid.ive'] == @resource[:ive]
        
        :insync
      end
    end

    newparam(:name) do
      isnamevar
    end

    newparam(:url) do
      defaultto 'localhost:5672'
    end

    # group 1 : Exchange options
    newparam(:type) do
    end

    # NOTE: auto delete on exchanges isn't supported by brokers, 
    #       though it appears to be a configurable flag in qpid-config
    # https://bugzilla.redhat.com/show_bug.cgi?id=518872
    #newparam(:auto_delete) do
    #end

    # group 2 : Options for Adding Exchanges and Queues
    newparam(:alt_exch) do
    end
    newparam(:durable) do
    end
    newparam(:replicate) do
    end

    # group 4 : Options for Adding Exchanges
    newparam(:msg_sequence) do
    end
    newparam(:ive) do
    end

    autorequire(:broker) do
      if @provider.resource[:url].is_a?(Array)
        @provider.resource[:url]
      else
        [ "#{@provider.resource[:url]}" ]
      end
    end

    autorequire(:exchange) do
      unless @provider.resource[:alt_exch].nil? 
        [ "#{@provider.resource[:alt_exch]}" ]
      end
    end

  end

end

