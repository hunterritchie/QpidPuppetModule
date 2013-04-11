require 'qpid_messaging'
require 'qpid_management'
require File.dirname(__FILE__) + '/../../common/functions'


Puppet::Type.type(:link).provide(:qpid) do

  include CreateDestroyExists

  attr_accessor :broker

  def _create(url)
    @broker = Qpid::setBroker(url)
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


  def _destroy(url)
    @broker = Qpid::setBroker(url)
    @broker.delete_link(@resource[:name])
  end

  def _exists?(url)
    @broker = Qpid::setBroker(url)
    return true unless @broker.link(@resource[:name]).nil?
    false
  end

end

