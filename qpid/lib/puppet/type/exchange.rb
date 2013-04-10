require File.dirname(__FILE__) + '/../common/functions'

module Puppet

  newtype(:exchange) do
    @doc = "Create an exchange on a qpidd broker."

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
        exchange = broker[url].exchange(@resource[:name])

        return :outofsync if exchange.nil?
        return :outofsync unless exchange.content['_values']['type'] == @resource[:type].to_s

        unless @resource[:alt_exch].nil?  and exchange.content['_values']['altExchange'].nil?
          fq_resource_altexch = "org.apache.qpid.broker:exchange:#{@resource[:alt_exch]}"
          fq_qpid_altexch = exchange.content['_values']['altExchange']['_object_name'] unless exchange.content['_values']['altExchange'].nil?
          return :outofsync unless fq_resource_altexch == fq_qpid_altexch
        end
      
        durable = @resource[:durable].nil? ? false : @resource[:durable]
        return :outofsync unless exchange.content['_values']['durable'].to_s == durable.to_s

        return :outofsync unless exchange.content['_values']['arguments']['replicate'].to_s == @resource[:replicate].to_s
        return :outofsync unless exchange.content['_values']['arguments']['qpid.msg_sequence'].to_s == @resource[:msg_sequence].to_s
        return :outofsync unless exchange.content['_values']['arguments']['qpid.ive'].to_s == @resource[:ive].to_s
        
        :insync
      end
    end

    newparam(:name) do
      desc "The name of the exchange."
      isnamevar
    end

    newparam(:url) do
      desc "The url of the qpidd broker, in the format of <ipaddr>:<port> or <hostname>:<port>. An array of urls may be provided."
      defaultto 'localhost:5672'
    end

    # group 1 : Exchange options
    newparam(:type) do
      desc "The type of the exchange, acceptable values are direct, fanout, topic, headers, and xml."
      newvalues(:direct, :fanout, :topic, :headers, :xml)
    end

    # NOTE: auto delete on exchanges isn't supported by brokers, 
    #       though it appears to be a configurable flag in qpid-config
    # https://bugzilla.redhat.com/show_bug.cgi?id=518872
    #newparam(:auto_delete) do
    #end

    # group 2 : Options for Adding Exchanges and Queues
    newparam(:alt_exch) do
      desc "The name of the alternate exchange."
    end
    newparam(:durable) do
      desc "Exchange is durable."
      newvalues(true, false)
    end
    newparam(:replicate) do
      desc "Replication level in HA cluster."
      newvalues(:none, :configuration, :all)
    end

    # group 4 : Options for Adding Exchanges
    newparam(:msg_sequence) do
      desc "Insert qpid.msg_sequence header in messages."
      newvalues(true, false)
    end
    newparam(:ive) do
      desc "Behave as intial value exchange."
      newvalues(true, false)
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

