require 'qpid_messaging'
require 'qpid_management'
require File.dirname(__FILE__) + '/../../common/functions'


Puppet::Type.type(:queue_route).provide(:qpid) do

  include CreateDestroyExists

  attr_accessor :broker

  def _create(url)
    @broker = Qpid::setBroker(url)

    options = {}
    options[:link] = @resource[:link]
    options[:queue] = @resource[:src_queue]
    options[:exchange] = @resource[:dst_exch]
    options[:sync] = @resource[:sync]

    @broker[url].add_queue_route(@resource[:name], options)
  end

  def _destroy(url)
    @broker = Qpid::setBroker(url)
    begin
      @broker[url].delete_bridge(@resource[:name])
    rescue
    end
  end

  def _exists?(url)
    @broker = Qpid::setBroker(url)
    @broker[url].bridges.each do |bridge|
      if @resource[:name] == bridge['name']
        return true
      end
    end
    false
  end

end

