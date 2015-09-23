require 'puppet/provider'
require 'puppet/util/network_device/solidfire/device'

Puppet::Type.type(:solidfire_account).provide(:linux) do
  desc "Manage SolidFire account creation and deletion."
  confine :feature => :posix

  #connection = SfRPC.new('https://' + @resource[:login] + ':' + @resource[:passwd] + '@' + @resource[:mvip] + '/json-rpc/8.0')

  def exists?
    Puppet.debug("#{self.class}::exists: #{@resource[:name]}")
    begin
      @connection = SfRPC.new('https://' + @resource[:login] + ':' + @resource[:passwd] + '@' + @resource[:mvip] + '/json-rpc/8.0')
      account = @connection.GetAccountByName({"username" => @resource[:name]})
    rescue Puppet::ExecutionFailure => e
    rescue SfRPC::JSONRPCError => e
      return false
    end
    if account then true else false end
  end

  def create
    Puppet.debug("#{self.class}::create: #{@resource[:name]}")
    @connection.AddAccount({"username" => @resource[:name] })
  end

  def destroy
    Puppet.debug("#{self.class}::destroy: #{@resource[:name]}")
    accountID = @connection.GetAccountByName({ "username" => @resource[:name]})['account']['accountID']
    @connection.RemoveAccount( { "accountID" => accountID })
  end

end
