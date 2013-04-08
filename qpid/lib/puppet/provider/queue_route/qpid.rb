require 'qpid_messaging'
require 'qpid_management'

Puppet::Type.type(:queue_route).provide(:qpid) do

  attr_accessor :broker

  def create
    setBroker

    options = {}
    options[:link] = @resource[:link]
    options[:queue] = @resource[:src_queue]
    options[:exchange] = @resource[:dst_exch]
    options[:sync] = @resource[:sync]

    @broker.add_queue_route(@resource[:name], options)
  end

  def destroy
    setBroker
    begin
      @broker.delete_bridge(@resource[:name])
    rescue
    end
  end

  def exists?
    setBroker
    @broker.bridges.each do |bridge|
      if @resource[:name] == bridge['name']
        return true
      end
    end
    false
  end

  def setBroker
    con = Qpid::Messaging::Connection.new(:url=>@resource[:url])
    con.open
    agent = Qpid::Management::BrokerAgent.new(con)
    @broker = agent.broker
  end

end

