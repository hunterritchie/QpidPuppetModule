require 'qpid_messaging'
require 'qpid_management'
require File.dirname(__FILE__) + '/../../common/functions'


Puppet::Type.type(:queue).provide(:qpid) do

  include CreateDestroyExists

  attr_accessor :broker

  def _create(url)
    @broker = Qpid::setBroker(url)
    begin
      options = {}
      # group 1
      options['auto-delete'] = @resource[:auto_delete] if @resource[:auto_delete]

      # group 2
      options['alternate-exchange'] = @resource[:alt_exch] if @resource[:alt_exch]
      options['durable'] = @resource[:durable] if @resource[:durable]
      options['qpid.replicate'] = @resource[:replicate] if @resource[:replicate]

      # group 3
      options['qpid.cluster_durable'] = @resource[:cluster_durable] if @resource[:cluster_durable]
      options['qpid.file_count'] = @resource[:file_count] if @resource[:file_count]
      options['qpid.file_size'] = @resource[:file_size] if @resource[:file_size]
      options['qpid.max_size'] = @resource[:max_size] if @resource[:max_size]
      options['qpid.max_count'] = @resource[:max_count] if @resource[:max_count]
      options['qpid.policy_type'] = @resource[:policy_type] if @resource[:policy_type]
      options['qpid.last_value_queue_key'] = @resource[:last_value_queue_key] if @resource[:last_value_queue_key]
      options['qpid.queue_event_generation'] = @resource[:queue_event_generation] if @resource[:queue_event_generation]
      options['qpid.flow_stop_size'] = @resource[:flow_stop_size] if @resource[:flow_stop_size]
      options['qpid.flow_resume_size'] = @resource[:flow_resume_size] if @resource[:flow_resume_size]
      options['qpid.flow_stop_count'] = @resource[:flow_stop_count] if @resource[:flow_stop_count]
      options['qpid.flow_resume_count'] = @resource[:flow_resume_count] if @resource[:flow_resume_count]
      options['qpid.group_header_key'] = @resource[:group_header_key] if @resource[:group_header_key]
      options['qpid.shared_msg_group'] = @resource[:shared_msg_group] if @resource[:shared_msg_group]

      @broker.add_queue(@resource[:name], options);
    rescue
    end
  end

  def _destroy(url)
    @broker = Qpid::setBroker(url)
    begin
      @broker.delete_queue(@resource[:name]);
    rescue
    end
  end

  def _exists?(url)
    @broker = Qpid::setBroker(url)
    return true unless @broker.queue(@resource[:name]).nil?
    false
  end

end

