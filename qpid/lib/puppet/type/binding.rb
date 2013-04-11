require File.dirname(__FILE__) + '/../common/functions'

module Puppet

  newtype(:binding) do
    @doc = "Create a binding from a queue to an exchange on a qpidd broker."
    
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
        exchange, queue, key = @resource[:name].split(':')
        id = "org.apache.qpid.broker:exchange:#{exchange},org.apache.qpid.broker:queue:#{queue},#{key}"
        binding = broker.binding(id)

        return :outofsync if binding.nil?
        :insync
      end
    end


    newparam(:name) do
      desc "The binding name is in the format of <exchange>:<queue>:<key>.  The key may be empty."
      isnamevar
    end

    newparam(:url) do
      desc "The url of the qpidd broker, in the format of <ipaddr>:<port> or <hostname>:<port>. An array of urls may be provided."
      isnamevar
      defaultto 'localhost:5672'
    end

    autorequire(:broker) do
      [ "#{@provider.resource[:url]}" ]
    end

    autorequire(:exchange) do
      name_ary = value(:name).split(':')
      [ "#{name_ary[0]}@#{@provider.resource[:url]}" ]
    end

    autorequire(:queue) do
      name_ary = value(:name).split(':')
      [ "#{name_ary[1]}@#{@provider.resource[:url]}" ]
    end


  end
end

