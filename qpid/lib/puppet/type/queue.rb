require File.dirname(__FILE__) + '/../common/functions'

module Puppet

  newtype(:queue) do
    @doc = "Create a queue on a qpidd broker."

    def self.title_patterns
      [ [ /(.*)@(.*)/m, [ [:name, lambda{|x| x}], [:url, lambda{|x| x}]  ] ] ]
    end

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
        queue = broker.queue(@resource[:name])

        return :outofsync if queue.nil?

      # group 1
        auto_delete = @resource[:auto_delete].nil? ? false : @resource[:auto_delete]
        return :outofsync unless queue.content['_values']['autoDelete'].to_s == auto_delete.to_s

      # group 2
        unless @resource[:alt_exch].nil? and queue.content['_values']['altExchange'].nil?
          fq_resource_altexch = "org.apache.qpid.broker:exchange:#{@resource[:alt_exch]}"
          fq_qpid_altexch = queue.content['_values']['altExchange']['_object_name'] unless queue.content['_values']['altExchange'].nil?
          return :outofsync unless fq_resource_altexch == fq_qpid_altexch
        end

        durable = @resource[:durable].nil? ? false : @resource[:durable]
        return :outofsync unless queue.content['_values']['durable'].to_s == durable.to_s

        return :outofsync unless queue.content['_values']['arguments']['qpid.replicate'].to_s == @resource[:replicate].to_s

      # group 3
        return :outofsync unless queue.content['_values']['arguments']['qpid.cluster_durable'].to_s == @resource[:cluster_durable].to_s
        return :outofsync unless queue.content['_values']['arguments']['qpid.file_count'] == @resource[:file_count]
        return :outofsync unless queue.content['_values']['arguments']['qpid.file_size'] == @resource[:file_size]
        return :outofsync unless queue.content['_values']['arguments']['qpid.max_size'] == @resource[:max_size]
        return :outofsync unless queue.content['_values']['arguments']['qpid.max_count'] == @resource[:max_count]
        return :outofsync unless queue.content['_values']['arguments']['qpid.policy_type'] == @resource[:policy_type]
        return :outofsync unless queue.content['_values']['arguments']['qpid.last_value_queue_key'] == @resource[:last_value_queue_key]
        return :outofsync unless queue.content['_values']['arguments']['qpid.queue_event_generation'].to_s == @resource[:queue_event_generation].to_s
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
      desc "The name of the queue."
      isnamevar
    end

    newparam(:url) do
      desc "The url of the qpidd broker, in the format of <ipaddr>:<port> or <hostname>:<port>. An array of urls may be provided."
      isnamevar
      defaultto 'localhost:5672'
    end

    # group 1 : options 
    newparam(:auto_delete) do
      desc "Queue is destroyed when no longer used."
      newvalues(true, false)
    end

    # group 2 : Options for Adding Exchanges and Queues
    newparam(:alt_exch) do
      desc "The name of the alternate exchange."
    end

    newparam(:durable) do
      desc "Queue is durable."
      newvalues(true, false)
    end

    newparam(:replicate) do
      desc "Replication level in HA cluster."
      newvalues(:none, :configuration, :all)
    end

    # group 3 : Options for Adding Queues
    newparam(:cluster_durable) do
      desc "Queue becomes durable if only one functioning node in cluster."
      newvalues(true, false)
    end

    newparam(:file_count) do
      desc "Number of files in queue's persistence journal."
    end

    newparam(:file_size) do
      desc "File size in pages (64KiB/page)."
    end

    newparam(:max_size) do
      desc "Maximum in-memory queue size as bytes."
    end

    newparam(:max_count) do
      desc "Maximum in-memory queue size as a number of messages."
    end

    newparam(:policy_type) do
      desc "Action to take when queue limit is reached."
    end

    newparam(:last_value_queue_key) do
      desc "Last Value Queue key."
    end

    newparam(:queue_event_generation) do
      desc "If set to 1, every enqueue will generate an event that can be processed by registered listeners (e.g. for replication). If set to 2, events will be generated for enqueues and dequeues."
      newvalues(1, 2)
    end

    newparam(:flow_stop_size) do
      desc "Turn on sender flow control when the number of queued bytes exceeds this value."
    end

    newparam(:flow_resume_size) do
      desc "Turn off sender flow control when the number of queued bytes drops below this value."
    end

    newparam(:flow_stop_count) do
      desc "Turn on sender flow control when the number of queued messages exceeds this value."
    end

    newparam(:flow_resume_count) do
      desc "Turn off sender flow control when the number of queued messages drops below this value."
    end

    newparam(:group_header_key) do
      desc "Enable message groups. Specify name of header that holds group identifier."
    end

    newparam(:shared_msg_group) do
      desc "Allow message group consumption across multiple consumers."
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
        [ "#{@provider.resource[:alt_exch]}@#{@provider.resource[:url]}" ]
      end
    end

  end

end

