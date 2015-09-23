require 'puppet/util/network_device'
#require 'puppet/util/network_device/solidfire/facts'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class SfRPC
  def initialize(service_url)
    @uri = URI.parse(service_url)
  end

  def getVolumeByName(name)
    Puppet.debug("#{self.class}::getVolumeByName: #{name}")
    volList = ListActiveVolumes()
    volList['volumes'].each do |vol|
      if vol['name'] == name then
        return vol
      end
    end
    nil
  end

  def method_missing(name, *args)
    post_body = { 'method' => name,
                  'params' => args[0],
                  'id' => 'puppet-' + rand(999).to_s
                }.to_json
    Puppet.debug("#{self.class}::post_body: #{post_body}")
    resp = JSON.parse( http_post_request(post_body) )
    raise JSONRPCError, resp['error'] if resp['error']
    Puppet.debug("#{self.class}::post_result: #{resp['result']}")
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
