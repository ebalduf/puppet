require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class SfRPC
  def initialize(service_url)
    @uri = URI.parse(service_url)
  end

  def method_missing(name, *args)
    post_body = { 'method' => name, 'params' => Hash[*args.flatten], 'id' => 'jsonrpc' }.to_json
    resp = JSON.parse( http_post_request(post_body) )
    raise JSONRPCError, resp['error'] if resp['error']
    resp['result']
  end

  def http_post_request(post_body)
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(@uri.request_uri)
    request.basic_auth(@uri.user, @uri.password)
    request.content_type = 'application/json'
    request.body = post_body
    http.request(request).body
  end

  class JSONRPCError < RuntimeError; end
end

Puppet::Type.type(:solidfire).provide(:linux) do
  confine :kernel => [:Linux]
  confine :osfamily => [:Debian]
  defaultfor :kernel => :Linux

  commands :iscsi => '/usr/bin/iscsiadm', 
           :mkdir => 'mkdir'

  def exists?
    begin
      sfrpc = SfRPC.new('https://' + resource[:login] + ':' + resource[:passwd] + '@' + resource[:mvip] + '/json-rpc/8.0')
      volList = sfrpc.ListActiveVolumes()
    rescue Puppet::ExecutionFailure => e
      false
    end
    volList['volumes'].each do |vol| 
      if vol['name'] == resource[:name] then
        return true
      end
    end
    return false
  end

  def create
    sfrpc = SfRPC.new('https://' + resource[:login] + ':' + resource[:passwd] + '@' + resource[:mvip] + '/json-rpc/8.0')
    sfrpc.CreateVolume("name", resource[:name], "accountID", resource[:account], "totalSize", resource[:size], "enable512e",true, "qos",{ "minIOPS" => 1600, "maxIOPS" => 15000, "burstIOPS" => 15000} )
  end

  def destroy
    thevol = Hash.new
    sfrpc = SfRPC.new('https://' + resource[:login] + ':' + resource[:passwd] + '@' + resource[:mvip] + '/json-rpc/8.0')
    volList = sfrpc.ListActiveVolumes()
    volList['volumes'].each do |vol| 
      if vol['name'] == resource[:name] then
        thevol = vol
        break
      end
    end
    sfrpc.DeleteVolume( "volumeID", thevol['volumeID'] )
  end

end

# commands parked for future development
#cluster = sfrpc.GetClusterInfo()
#iscsiadm('-m node -T', iqn.2010-01.com.solidfire:j2ud.test1.6 '-p', cluster['clusterInfo']['svip'] + ':3260')
