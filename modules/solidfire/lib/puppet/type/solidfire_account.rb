Puppet::Type.newtype(:solidfire_account) do
  @doc = "Manage Accounts on solidfire cluster"

  ensurable

  newparam(:name, :namevar => true) do
  end

  newparam(:mvip) do
  end

  newparam(:login) do
  end

  newparam(:passwd) do
  end

end
