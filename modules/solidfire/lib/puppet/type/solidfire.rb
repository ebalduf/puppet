Puppet::Type.newtype(:solidfire) do

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

  ensurable

  newproperty(:size) do
  end

end
