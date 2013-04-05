require 'qpid_messaging'
require 'qpid_management'

Puppet::Type.type(:link).provide(:qpid) do

  attr_accessor :broker

  def create
    setBroker
    durable = @resource[:durable].nil? ? false : @resource[:durable]
    auth = @resource[:auth].nil? ? '' : @resource[:auth]
    username = @resource[:username].nil? ? '' : @resource[:username]
    password = @resource[:password].nil? ? '' : @resource[:password]
    @broker.add_link( @resource[:name], 
                      @resource[:remote_host],
                      @resource[:remote_port],
                      @resource[:transport], 
                      durable, auth, username, password)

  end

  def destroy
    setBroker
    @broker.delete_link(@resource[:name])
  end

  def exists?
    setBroker
    return true unless @broker.link(@resource[:name]).nil?
    false
  end

  def setBroker
    con = Qpid::Messaging::Connection.new(:url=>@resource[:url]);
    con.open;
    agent = Qpid::Management::BrokerAgent.new(con);
    @broker = agent.broker;
  end

end

