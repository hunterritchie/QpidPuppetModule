
module Puppet

  newtype(:queue) do
    @doc = "the custom type for qpidd creates the connection and qmf agent"

    newproperty(:ensure) do
      defaultto :insync
      
      newvalue :insync do
        @resource.provider.destroy
        @resource.provider.create
      end

      newvalue :outofsync

      def retrieve
        broker = provider.setBroker
        queue = broker.queue(@resource[:name])

        return :outofsync if queue.nil?


      # group 1
        auto_delete = @resource[:auto_delete].nil? ? false : @resource[:auto_delete]
        return :outofsync unless queue.content['_values']['autoDelete'] == auto_delete

      # group 2
        unless @resource[:alt_exch].nil? and queue.content['_values']['altExchange'].nil?
          fq_resource_altexch = "org.apache.qpid.broker:exchange:#{@resource[:alt_exch]}"
          fq_qpid_altexch = queue.content['_values']['altExchange']['_object_name'] unless queue.content['_values']['altExchange'].nil?
          return :outofsync unless fq_resource_altexch == fq_qpid_altexch
        end

        durable = @resource[:durable].nil? ? false : @resource[:durable]
        return :outofsync unless queue.content['_values']['durable'] == durable

        return :outofsync unless queue.content['_values']['arguments']['qpid.replicate'] == @resource[:replicate]

      # group 3
        return :outofsync unless queue.content['_values']['arguments']['qpid.cluster_durable'] == @resource[:cluster_durable]
        return :outofsync unless queue.content['_values']['arguments']['qpid.file_count'] == @resource[:file_count]
        return :outofsync unless queue.content['_values']['arguments']['qpid.file_size'] == @resource[:file_size]
        return :outofsync unless queue.content['_values']['arguments']['qpid.max_size'] == @resource[:max_size]
        return :outofsync unless queue.content['_values']['arguments']['qpid.max_count'] == @resource[:max_count]
        return :outofsync unless queue.content['_values']['arguments']['qpid.policy_type'] == @resource[:policy_type]
        return :outofsync unless queue.content['_values']['arguments']['qpid.last_value_queue_key'] == @resource[:last_value_queue_key]
        return :outofsync unless queue.content['_values']['arguments']['qpid.queue_event_generation'] == @resource[:queue_event_generation]
        return :outofsync unless queue.content['_values']['arguments']['qpid.flow_stop_size'] == @resource[:flow_stop_size]
        return :outofsync unless queue.content['_values']['arguments']['qpid.flow_resume_size'] == @resource[:flow_resume_size]
        return :outofsync unless queue.content['_values']['arguments']['qpid.flow_stop_count'] == @resource[:flow_stop_count]
        return :outofsync unless queue.content['_values']['arguments']['qpid.flow_resume_count'] == @resource[:flow_resume_count]
        return :outofsync unless queue.content['_values']['arguments']['qpid.group_header_key'] == @resource[:group_header_key]
        return :outofsync unless queue.content['_values']['arguments']['qpid.shared_msg_group'] == @resource[:shared_msg_group]

        :insync
      end
    end

    newparam(:name) do
      isnamevar
    end

    newparam(:url) do
    end

    # group 1 : options 
    newparam(:auto_delete) do
    end

    # group 2 : Options for Adding Exchanges and Queues
    newparam(:alt_exch) do
    end

    newparam(:durable) do
    end

    newparam(:replicate) do
    end

    # group 3 : Options for Adding Queues
    newparam(:cluster_durable) do
    end

    newparam(:file_count) do
    end
    newparam(:file_size) do
    end
    newparam(:max_size) do
    end
    newparam(:max_count) do
    end
    newparam(:policy_type) do
    end
    newparam(:last_value_queue_key) do
    end
    newparam(:queue_event_generation) do
    end
    newparam(:flow_stop_size) do
    end
    newparam(:flow_resume_size) do
    end
    newparam(:flow_stop_count) do
    end
    newparam(:flow_resume_count) do
    end
    newparam(:group_header_key) do
    end
    newparam(:shared_msg_group) do
    end

    autorequire(:broker) do
      [ "#{@provider.resource[:url]}" ]
    end

    autorequire(:exchange) do
      unless @provider.resource[:alt_exch].nil?
        [ "#{@provider.resource[:alt_exch]}" ]
      end
    end

  end

end

