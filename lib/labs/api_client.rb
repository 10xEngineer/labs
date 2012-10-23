# encoding: utf-8

require 'httparty'
require 'openssl'
require 'base64'
require 'uri'

module Labs
	class Client
		include HTTParty

		format :json

		def initialize(endpoint, token, secret)
			@uri = URI.parse(endpoint)
			@token = token
			@secret = secret

			@digest = OpenSSL::Digest::Digest.new('sha256')

			Client.base_uri HTTParty.normalize_base_uri(@uri.to_s)
		end

		def get(resource, resource_id)
      		get_ext resource_path(resource, resource_id)
    	end

		def get_ext(path)
			response = perform_request(
			            :get,
			            path,
			            default_headers)

			unless response.response.kind_of? Net::HTTPOK
				raise response.parsed_response["message"]
			end

			response.parsed_response
		end

	private

		def default_headers
			headers = {
				'Accept' => 'application/json',
				'Date' => Time.now.utc.strftime("%a, %e %b %Y %H:%M:%S %Z"),
				'X-Labs-Token' => @token
			}
		end

		def signature(data)
			hmac = OpenSSL::HMAC.digest(@digest, @secret, data)

			Base64.encode64(hmac)
		end

		def perform_request(method, path, options)
			headers = default_headers

			data = ""
			data << method.to_s.upcase
			data << path
			data << headers['Date']
			data << headers['X-Labs-Token']
			data << options[:body] if options[:body]

			headers['X-Labs-Signature'] = signature(data)

			headers.merge(options[:headers]) if options[:headers]
			options[:headers] = headers

			self.class.send(method.to_s, path, options)
	    end		
	end	
end