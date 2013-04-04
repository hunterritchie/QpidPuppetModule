require 'qpid_messaging'
require 'qpid_management'

Puppet::Type.type(:queue).provide(:qpid) do

  attr_accessor :broker

  def create
    setBroker
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

      puts("queue create options = #{options}")
      puts("create queue #{@resource[:name]}");
      @broker.add_queue(@resource[:name], options);
    rescue
    end

  end

  def destroy
    setBroker
    begin
      puts("delete queue #{@resource[:name]}");
      @broker.delete_queue(@resource[:name]);
    rescue
    end
  end

  def exists?
    setBroker
    return true unless @broker.queue(@resource[:name]).nil?
    false
  end

  def setBroker
    if broker.nil?
      con = Qpid::Messaging::Connection.new(:url=>@resource[:url]);
      con.open;
      agent = Qpid::Management::BrokerAgent.new(con);
      @broker = agent.broker;
    end
  end

=begin
  def self.setBroker(url)
    if @broker.nil?
      con = Qpid::Messaging::Connection.new(:url=>url);
      con.open;
      agent = Qpid::Management::BrokerAgent.new(con);
      @broker = agent.broker;
    end
  end

  def self.prefetch(resources)
    @@resource_list = resources
    resources.each do |name, resource|
      #puts("PREFETCH FOR #{name} @ #{resource.value(:url)}")
      broker = setBroker(resource.value(:url))
      queue = broker.queue(name)
      unless queue.nil?
        queue.content['_values'].each do |arg, val|
          #puts("ARG = #{arg} \t\t\t: VAL = #{val}")
          ##resource[arg.to_sym] = val if resource.respond_to?(arg.to_sym)
        end
      end
    end
  end
=end

end

