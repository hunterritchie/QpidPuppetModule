require 'qpid_messaging'
require 'qpid_management'

Puppet::Type.type(:binding).provide(:qpid) do

  attr_accessor :broker
  attr_accessor :exchange
  attr_accessor :queue
  attr_accessor :key

  def create
    setBroker
    @broker.add_binding(@exchange, @queue, @key);
  end

  def destroy
    setBroker
    @broker.delete_binding(@exchange, @queue, @key);
  end

  def exists?
    setBroker
    id = "org.apache.qpid.broker:exchange:#{exchange},org.apache.qpid.broker:queue:#{queue},#{key}"
    return true unless @broker.binding(id).nil?
    false
  end

  def setValues
    name_ary = @resource[:name].split(':')
    @exchange = name_ary[0]
    @queue = name_ary[1]
    @key = name_ary[2] || ''
  end

  def setBroker
    setValues
    con = Qpid::Messaging::Connection.new(:url=>@resource[:url]);
    con.open;
    agent = Qpid::Management::BrokerAgent.new(con);
    @broker = agent.broker;
  end

end

