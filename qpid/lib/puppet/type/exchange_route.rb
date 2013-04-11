require File.dirname(__FILE__) + '/../common/functions'

module Puppet

  newtype(:exchange_route) do
    @doc = "Creates an exchange route between exchanges with the provided key, using the specified link."

    def self.title_patterns
      [ [ /(.*)@(.*)/m, [ [:name, lambda{|x| x}], [:url, lambda{|x| x}]  ] ] ]
    end

    newproperty(:ensure) do
      defaultto :insync

      newvalue :insync do
        @resource.provider.destroy
        @resource.provider.create
      end

      newvalue :outofsync

      include Retrieve

      def _retrieve(url)
        broker = Qpid::setBroker(url)
        broker.bridges.each do |bridge|
          if @resource[:name] == bridge['name']
            return :outofsync unless bridge['dest'] == @resource[:exchange]
            return :outofsync unless bridge['src'] == @resource[:exchange]
            return :outofsync unless bridge['sync'].to_s == @resource[:sync].to_s
            return :outofsync unless bridge['dynamic'] == false
            return :outofsync unless bridge['key'] == @resource[:key]
            return :outofsync unless bridge['linkRef'] == @resource[:link]
            return :insync
          end
        end
        return :outofsync
      end
    end

    newparam(:name) do
      desc "The exchange route name."
      isnamevar
    end

    newparam(:url) do
      desc "The url of the qpidd broker, in the format of <ipaddr>:<port> or <hostname>:<port>. An array of urls may be provided."
      isnamevar
      defaultto 'localhost:5672'
    end

    newparam(:link) do
      desc "The name of the link to use."
    end

    newparam(:exchange) do
      desc "The name of the exchange to use."
    end

    newparam(:key) do
      desc "The key for the bridge."
    end

    newparam(:sync) do
      desc "Acknowledge transfers over the bridge in batches of N."
    end

    autorequire(:broker) do
      [ "#{@provider.resource[:url]}" ]
    end

    autorequire(:link) do
      [ "#{@provider.resource[:link]}@#{@provider.resource[:url]}" ]
    end

    autorequire(:exchange) do
      [ "#{@provider.resource[:exchange]}@#{provider.resource[:url]}" ]
    end

  end

end

