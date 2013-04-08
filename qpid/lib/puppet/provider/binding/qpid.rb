require 'qpid_messaging'
require 'qpid_management'

Puppet::Type.type(:binding).provide(:qpid) do

  attr_accessor :broker
  attr_accessor :exchange
  attr_accessor :queue
  attr_accessor :key

  def create
    if @resource[:url].is_a?(Array)
      @resource[:url].each { |url| create_binding(url) }
    else
      create_binding(@resource[:url])
    end
  end

  def create_binding(url)
    setBroker(url)
    @broker[url].add_binding(@exchange, @queue, @key);
  end


  def destroy
    if @resource[:url].is_a?(Array)
      @resource[:url].each { |url| destroy_binding(url) }
    else
      destroy_binding(@resource[:url])
    end
  end

  def destroy_binding(url)
    setBroker(url)
    @broker[url].delete_binding(@exchange, @queue, @key);
  end


  def exists?
    if @resource[:url].is_a?(Array)
      exists = true
      @resource[:url].each { |url| exists = false if false == binding_exists?(url) }
      exists
    else
      binding_exists?(@resource[:url])
    end
  end

  def binding_exists?(url)
    setBroker(url)
    id = "org.apache.qpid.broker:exchange:#{exchange},org.apache.qpid.broker:queue:#{queue},#{key}"
    return true unless @broker.binding(id).nil?
    false
  end

  def setValues
    @exchange, @queue, @key = @resource[:name].split(':')
  end

  def setBroker(url=@resource[:url])
    setValues
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

