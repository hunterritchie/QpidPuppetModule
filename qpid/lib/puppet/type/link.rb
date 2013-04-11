require File.dirname(__FILE__) + '/../common/functions'

module Puppet

  newtype(:link) do
    @doc = "Create a link between qpidd brokers."

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
        link = broker.link(@resource[:name])
        return :outofsync if link.nil?
        return :outofsync unless link['host'] == @resource[:remote_host]
        return :outofsync unless link['port'].to_s == @resource[:remote_port].to_s
        return :outofsync unless link['transport'] == @resource[:transport]
        durable = @resource[:durable].nil? ? false : @resource[:durable]
        return :outofsync unless link['durable'].to_s == durable.to_s
        return :insync
      end
    end

    newparam(:name) do
      desc "The name of the link."
      isnamevar
    end

    newparam(:url) do
      desc "The url of the qpidd broker, in the format of <ipaddr>:<port> or <hostname>:<port>. An array of urls may be provided."
      isnamevar
      defaultto 'localhost:5672'
    end

    newparam(:remote_host) do
      desc "The ip address or host name of the remote broker."
    end

    newparam(:remote_port) do
      desc "The port of the remote broker."
    end

    newparam(:transport) do
      desc "The transport to use for links."
      defaultto 'tcp'
    end

    newparam(:durable) do
      desc "Link is durable."
      newvalues(true, false)
    end

    newparam(:auth) do
      desc "SASL mechanism for authentication (e.g. EXTERNAL, ANONYMOUS, PLAIN, CRAM-MD, DIGEST-MD5, GSSAPI). Used when the client connects to the destination broker (not for authentication between the source and destination brokers - that is specified using the [mechanisms] argument to 'add route'). SASL automatically picks the most secure available mechanism - use this option to override."
    end

    newparam(:username) do
    end

    newparam(:password) do
    end

    autorequire(:broker) do
      [ "#{@provider.resource[:url]}" ]
    end

  end

end

