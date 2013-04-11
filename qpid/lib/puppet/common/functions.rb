
# every type and provider needs this
module Qpid
  
  def self.setBroker(url)
    if @broker.nil?
      con = Qpid::Messaging::Connection.new(:url=>url);
      con.open;
      agent = Qpid::Management::BrokerAgent.new(con);
      @broker = agent.broker;
    end
    @broker
  end

end


# every provider needs these
module CreateDestroyExists

  def create
    _create(@resource[:url])
  end

  def destroy
    _destroy(@resource[:url])
  end

  def exists?
    _exists?(@resource[:url])
  end

end


module Retrieve

  def retrieve
    return _retrieve(@resource[:url])
  end

end


