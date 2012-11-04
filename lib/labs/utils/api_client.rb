# encoding: utf-8

require 'active_support/inflector'
require 'httparty'
require 'openssl'
require 'base64'
require 'yajl'
require 'uri'

begin
	require 'rbconfig'

	CONFIG = RbConfig::CONFIG
rescue LoadError	
end

module Labs
	class APIClient
		include HTTParty

		API_VERSION = "v1"

		format :json

		def initialize(endpoint, token, secret)
			@uri = URI.parse(endpoint)
			@token = token
			@secret = secret

			@digest = OpenSSL::Digest::Digest.new('sha256')

			APIClient.base_uri HTTParty.normalize_base_uri(@uri.to_s)
		end

		def get(resource, resource_id)
      		get_ext resource_path(resource, resource_id)
    	end

		def get_ext(path)
			response = perform_request(
			            :get,
			            path,
			            {})

			unless response.response.kind_of? Net::HTTPOK
				raise response.parsed_response["message"]
			end

			response.parsed_response
		end

		def post(resource, resource_id = nil, data = {})
			post_ext resource_path(resource, resource_id), data
		end

		def post_ext(path, data)
			options = {}
			options[:body] = Yajl::Encoder.encode(data)

			response = perform_request(
                    :post,
                    path,
                    options)

			unless response.response.kind_of? Net::HTTPCreated
				raise response.parsed_response["message"]
			end

			response.parsed_response
		end

		def delete(resource, resource_id = nil)
			delete_ext resource_path(resource, resource_id)
		end

		def delete_ext(path)
			response = perform_request(
                    :delete,
                    path,
                    {})

			unless response.response.kind_of? Net::HTTPOK
				raise response.parsed_response["message"]
			end

			response.parsed_response
		end

	private

		def default_headers
			headers = {
				'Accept' => 'application/json',
				# TODO UTC missing on windows/ruby 1.8.7 (2008-08-11 patchlevel 72) [i386-cygwin]
				'Date' => Time.now.utc.strftime("%a, %e %b %Y %H:%M:%S UTC"),
				'X-Labs-Token' => @token,
				'User-Agent' => "labs-gem/#{Labs::VERSION} (#{CONFIG["host"]}) #{CONFIG["RUBY_INSTALL_NAME"]}/#{RUBY_VERSION}-p#{CONFIG["PATCHLEVEL"]} "
			}
		end

		def signature(data)
			hmac = OpenSSL::HMAC.digest(@digest, @secret, data)

			Base64.encode64(hmac)
		end

		def resource_path(resource, resource_id = nil, append = nil)
		  path = "/#{resource.to_s.pluralize}"
		  path << "/#{resource_id}" if resource_id
		  path << "/#{append}" if append

		  path
		end

		def perform_request(method, path, options)
			headers = default_headers

			APIClient.debug_output if $verbose

			data = ""
			data << method.to_s.upcase
			data << path
			data << headers['Date']
			data << headers['X-Labs-Token']
			data << options[:body] if options[:body]

			headers['X-Labs-Signature'] = signature(data)

			headers.merge(options[:headers]) if options[:headers]
			options[:headers] = headers

			full_path = "/#{API_VERSION}" + path
			
			res = self.class.send(method.to_s, full_path, options)

			if [500,502,503,504].include?(res.response.code.to_i)
				if res.parsed_response && res.parsed_response["message"]
					raise "API internal error #{res.response.code}: #{res.parsed_response["message"]}"
				else
					raise "API internal error #{res.response.code}"
				end
			end

			res
	    end		
	end	
end