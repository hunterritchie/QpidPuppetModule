module Puppet::Parser::Functions
  newfunction(:url_addr, :type => :rvalue) do |args|
    addr, port = args[0].split(':')
    addr
  end
end
