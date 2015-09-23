require 'puppet/provider'
require 'puppet/util/network_device/solidfire/device'

Puppet::Type.type(:solidfire_volume).provide(:linux) do
  desc "Manage SolidFire Volume creation, modification and deletion."
  confine :feature => :posix

  #connection = SfRPC.new('https://' + @resource[:login] + ':' + @resource[:passwd] + '@' + @resource[:mvip] + '/json-rpc/8.0')

  def exists?
    Puppet.debug("#{self.class}::exists: #{@resource[:name]}")
    begin
      @connection = SfRPC.new('https://' + @resource[:login] + ':' + @resource[:passwd] + '@' + @resource[:mvip] + '/json-rpc/8.0')
      thevol = @connection.getVolumeByName(@resource[:name])
    rescue Puppet::ExecutionFailure => e
      false
    end
    if thevol then true else false end
  end

  def create
    Puppet.debug("#{self.class}::create: #{@resource[:name]} #{@resource[:volsize]}")
    size = Integer(@resource[:volsize]) * 1000000000
    accountID = @connection.GetAccountByName({ "username" => @resource[:account]})["account"]["accountID"]
    @connection.CreateVolume({"name" => @resource[:name], 
                              "accountID" => accountID,
                              "totalSize" => size,
                              "enable512e" => true,
                              "qos" => { "minIOPS" => @resource[:min_iops], 
                                         "maxIOPS" => @resource[:max_iops],
                                         "burstIOPS" => @resource[:burst_iops]}
                              })
  end

  def destroy
    Puppet.debug("#{self.class}::destroy: #{@resource[:name]}")
    thevol = @connection.getVolumeByName(@resource[:name])
    @connection.DeleteVolume( { "volumeID" => thevol['volumeID'] })
  end

  def volsize
    Puppet.debug("#{self.class}::volsize: #{@resource[:volsize]}")
    thevol = @connection.getVolumeByName(@resource[:name])
    Puppet.debug("#{self.class}::volsize: result -> #{thevol['totalSize'] / 1000000000}")
    (thevol['totalSize'] / 1000000000).to_s
  end

  def volsize=(value)
    Puppet.debug("#{self.class}::volsize=(value): size #{@resource[:volsize]}.")
    thevol = @connection.getVolumeByName(@resource[:name])
    size = Integer(value) * 1000000000
    @connection.ModifyVolume( {"volumeID" => thevol['volumeID'], "totalSize" => size })
  end

  def min_iops
    Puppet.debug("#{self.class}::min_iops: #{@resource[:min_iops]}")
    thevol = @connection.getVolumeByName(@resource[:name])
    Puppet.debug("#{self.class}::min_iops: result -> #{thevol['qos']['minIOPS']}")
    thevol['qos']['minIOPS'].to_s
  end

  def min_iops=(value)
    Puppet.debug("#{self.class}::min_iops=(value): min_iops #{value}.")
    thevol = @connection.getVolumeByName(@resource[:name])
    @connection.ModifyVolume( {"volumeID" => thevol['volumeID'], 
                               "qos" => { "minIOPS" => @resource[:min_iops],
                                          "maxIOPS" => @resource[:max_iops],
                                          "burstIOPS" => @resource[:burst_iops] }} )
  end

  def max_iops
    Puppet.debug("#{self.class}::max_iops: #{@resource[:max_iops]}")
    thevol = @connection.getVolumeByName(@resource[:name])
    Puppet.debug("#{self.class}::max_iops: result -> #{thevol['qos']['maxIOPS']}")
    thevol['qos']['maxIOPS'].to_s
  end

  def max_iops=(value)
    Puppet.debug("#{self.class}::max_iops=(value): max_iops #{value}.")
    thevol = @connection.getVolumeByName(@resource[:name])
    @connection.ModifyVolume( {"volumeID" => thevol['volumeID'], 
                               "qos" => { "minIOPS" => @resource[:min_iops],
                                          "maxIOPS" => @resource[:max_iops],
                                          "burstIOPS" => @resource[:burst_iops] }} )
  end

  def burst_iops
    Puppet.debug("#{self.class}::burst_iops: #{@resource[:burst_iops]}")
    thevol = @connection.getVolumeByName(@resource[:name])
    Puppet.debug("#{self.class}::burst_iops: result -> #{thevol['qos']['burstIOPS']}")
    thevol['qos']['burstIOPS'].to_s
  end

  def burst_iops=(value)
    Puppet.debug("#{self.class}::burst_iops=(value): burst_iops #{value}.")
    thevol = @connection.getVolumeByName(@resource[:name])
    @connection.ModifyVolume( {"volumeID" => thevol['volumeID'], 
                               "qos" => { "minIOPS" => @resource[:min_iops],
                                          "maxIOPS" => @resource[:max_iops],
                                          "burstIOPS" => @resource[:burst_iops] }} )
  end

end
