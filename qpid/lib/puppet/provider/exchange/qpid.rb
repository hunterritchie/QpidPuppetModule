require 'qpid_messaging'
require 'qpid_management'

Puppet::Type.type(:exchange).provide(:qpid) do

  attr_accessor :broker

  def create
    if @resource[:url].is_a?(Array)
      @resource[:url].each { |url| create_exchange(url) }
    else
      create_exchange(@resource[:url])
    end
  end

  def create_exchange(url)
    setBroker(url)
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

      @broker[url].add_exchange(@resource[:type], @resource[:name], options);
    rescue
    end
  end

  def destroy
    if @resource[:url].is_a?(Array)
      @resource[:url].each { |url| destroy_exchange(url) }
    else
      destroy_exchange(@resource[:url])
    end
  end

  def destroy_exchange(url)
    setBroker(url)
    # delete other exchanges that use this exchange as an alternate-exchange
    qpid_exchange_name = "org.apache.qpid.broker:exchange:#{@resource[:name]}"

    # remove any exchanges *this is alternate to
    @broker[url].exchanges.each do |ex|
      if @resource[:name] == ex['altExchange']
        begin
          @broker[url].delete_exchange(ex['name'])
        rescue
        end
      end
    end

    # remove any queues *this is alternate to
    @broker[url].queues.each do |q|
      unless q['altExchange'].nil?
        if @resource[:name] == q['altExchange']
          begin
            @broker[url].delete_queue(q['name'])
          rescue
          end
        end
      end
    end

    begin
      @broker[url].delete_exchange(@resource[:name]);
    rescue
    end
  end

  def exists?
    if @resource[:url].is_a?(Array)
      exists = true
      @resource[:url].each { |url| exists = false if false == exchange_exists?(url) }
      exists
    else
      exchange_exists?(@resource[:url])
    end
  end

  def exchange_exists?(url)
    setBroker(url)
    return true unless @broker[url].exchange(@resource[:name]).nil?
    false
  end

  def setBroker(url=@resource[:url])
    @broker = {} if @broker.nil?
    if @broker[url].nil?
      con = Qpid::Messaging::Connection.new(:url=>url);
      con.open;
      agent = Qpid::Management::BrokerAgent.new(con);
      @broker[url] = agent.broker;
    end
    @broker
  end

end

