
# every type and provider needs this
module Qpid
  
  def self.setBroker(url)
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

# every provider needs these
module CreateDestroyExists

  def create
    if @resource[:url].is_a?(Array)
      @resource[:url].each { |url| _create(url) }
    else
      _create(@resource[:url])
    end
  end

  def destroy
    if @resource[:url].is_a?(Array)
      @resource[:url].each { |url| _destroy(url) }
    else
      _destroy(@resource[:url])
    end
  end

  def exists?
    if @resource[:url].is_a?(Array)
      exists = true
      @resource[:url].each { |url| exists = false if false == _exists?(url) }
      exists
    else
      _exists?(@resource[:url])
    end
  end

end

module Retrieve

 def retrieve
    if @resource[:url].is_a?(Array)
      sync = :insync
      @resource[:url].each { |url| sync = :outofsync if :outofsync == _retrieve(url) }
      return sync
    else
      return _retrieve(@resource[:url])
    end
  end

end
