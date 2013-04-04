module Puppet::Parser::Functions
  newfunction(:url_port, :type => :rvalue) do |args|
    addr, port = args[0].split(':')
    port
  end
end
