require 'qpid_messaging'
require 'qpid_management'
require File.dirname(__FILE__) + '/../../common/functions'


Puppet::Type.type(:exchange_route).provide(:qpid) do

  include CreateDestroyExists

  attr_accessor :broker

  def _create(url)
    @broker = Qpid::setBroker(url)

    options = {}
    options[:link] = @resource[:link]
    options[:exchange] = @resource[:exchange]
    options[:key] = @resource[:key]
    options[:sync] = @resource[:sync]

    @broker.add_exchange_route(@resource[:name], options)
  end

  def _destroy(url)
    @broker = Qpid::setBroker(url)
    @broker.delete_bridge(@resource[:name])
  end

  def _exists?(url)
    @broker = Qpid::setBroker(url)
    @broker.bridges.each do |bridge|
      if @resource[:name] == bridge['name']
        return true
      end
    end
    false
  end

end

