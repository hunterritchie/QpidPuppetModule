require 'qpid_messaging'
require 'qpid_management'
require File.dirname(__FILE__) + '/../../common/functions'


Puppet::Type.type(:exchange).provide(:qpid) do

  include CreateDestroyExists

  attr_accessor :broker

  def _create(url)
    @broker = Qpid::setBroker(url)
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

  def _destroy(url)
    @broker = Qpid::setBroker(url)
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

  def _exists?(url)
    @broker = Qpid::setBroker(url)
    return true unless @broker[url].exchange(@resource[:name]).nil?
    false
  end

end

