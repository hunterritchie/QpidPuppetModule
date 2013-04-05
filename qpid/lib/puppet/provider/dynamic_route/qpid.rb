require 'qpid_messaging'
require 'qpid_management'

Puppet::Type.type(:dynamic_route).provide(:qpid) do

  attr_accessor :broker

  def create
    setBroker

    options = {}
    options[:link] = @resource[:link]
    options[:exchange] = @resource[:exchange]
    options[:sync] = @resource[:sync]

    @broker.add_dynamic_route(@resource[:name], options)
  end

  def destroy
    setBroker
    @broker.delete_bridge(@resource[:name])
  end

  def exists?
    setBroker
    return true unless @broker.bridge(@resource[:name]).nil?
    false
  end

  def setBroker
    con = Qpid::Messaging::Connection.new(:url=>@resource[:url]);
    con.open;
    agent = Qpid::Management::BrokerAgent.new(con);
    @broker = agent.broker;
  end

end
