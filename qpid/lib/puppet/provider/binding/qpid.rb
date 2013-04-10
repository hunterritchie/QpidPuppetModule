require 'qpid_messaging'
require 'qpid_management'
require File.dirname(__FILE__) + '/../../common/functions'

Puppet::Type.type(:binding).provide(:qpid) do

  include CreateDestroyExists

  attr_accessor :broker
  attr_accessor :exchange
  attr_accessor :queue
  attr_accessor :key

  def _create(url)
    setValues
    @broker = Qpid::setBroker(url)
    @broker[url].add_binding(@exchange, @queue, @key);
  end


  def _destroy(url)
    setValues
    @broker = Qpid::setBroker(url)
    @broker[url].delete_binding(@exchange, @queue, @key);
  end


  def _exists?(url)
    @broker = Qpid::setBroker(url)
    id = "org.apache.qpid.broker:exchange:#{exchange},org.apache.qpid.broker:queue:#{queue},#{key}"
    return true unless @broker.binding(id).nil?
    false
  end

  def setValues
    @exchange, @queue, @key = @resource[:name].split(':')
  end

end

