Puppet::Type.newtype(:solidfire_volume) do
  @doc = "Manage Volumes on solidfire"

  ensurable

  newparam(:name, :namevar => true) do
  end

  newparam(:mvip) do
  end

  newparam(:login) do
  end

  newparam(:passwd) do
  end

  newparam(:account) do
  end

  #---------

  newproperty(:volsize) do
  end

  newproperty(:min_iops) do
  end

  newproperty(:max_iops) do
  end

  newproperty(:burst_iops) do
  end

end
