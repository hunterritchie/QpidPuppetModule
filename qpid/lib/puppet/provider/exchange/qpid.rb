require 'qpid_messaging'
require 'qpid_management'

Puppet::Type.type(:exchange).provide(:qpid) do

  attr_accessor :broker

  def create
    setBroker
    begin
      options = {}
      # group 1
      # 'type' not handled in options hash
      #options['auto-delete'] = @resource[:auto_delete] if @resource[:auto_delete]

      # group 2
      options['alternate-exchange'] = @resource[:alt_exch] if @resource[:alt_exch]
      options['durable'] = @resource[:durable] if @resource[:durable]
      options['replicate'] = @resource[:replicate] if @resource[:replicate]

      # group 3
      options['qpid.msg_sequence'] = @resource[:msg_sequence] if @resource[:msg_sequence]
      options['qpid.ive'] = @resource[:ive] if @resource[:ive]

      @broker.add_exchange(@resource[:type], @resource[:name], options);
    rescue
    end
  end

  def destroy
    setBroker

    # delete other exchanges that use this exchange as an alternate-exchange
    qpid_exchange_name = "org.apache.qpid.broker:exchange:#{@resource[:name]}"

    # remove any exchanges *this is alternate to
    @broker.exchanges.each do |ex|
      if @resource[:name] == ex['altExchange']
        begin
          @broker.delete_exchange(ex['name'])
        rescue
        end
      end
    end

    # remove any queues *this is alternate to
    @broker.queues.each do |q|
      unless q['altExchange'].nil?
        if @resource[:name] == q['altExchange']
          begin
            @broker.delete_queue(q['name'])
          rescue
          end
        end
      end
    end

    begin
      @broker.delete_exchange(@resource[:name]);
    rescue
    end
  end

  def exists?
    setBroker
    return true unless @broker.exchange(@resource[:name]).nil?
    false
  end

  def setBroker
    if @broker.nil?
      con = Qpid::Messaging::Connection.new(:url=>@resource[:url]);
      con.open;
      agent = Qpid::Management::BrokerAgent.new(con);
      @broker = agent.broker;
    end
  end

end

