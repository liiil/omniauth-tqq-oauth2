require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Tqq2 < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "tqq2"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site           => "https://open.t.qq.com",
        :authorize_url  => "/cgi-bin/oauth2/authorize",
        :token_url      => "/cgi-bin/oauth2/access_token"
      }
      option :token_params, {
        :parse          => :query
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid {
        access_token["openid"]
      }

      info do
        {
          :name => raw_info['name'],
          :email => raw_info['email']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      credentials do
        hash = {'token' => access_token.token}
        hash.merge!('openid' => @openid) if @openid
        hash.merge!('openkey' => @openkey) if @openkey
        hash.merge!('refresh_token' => access_token.refresh_token) if access_token.expires? && access_token.refresh_token
        hash.merge!('expires_at' => access_token.expires_at) if access_token.expires?
        hash.merge!('expires' => access_token.expires?)
        hash
      end

      def build_access_token
        verifier = request.params['code']
        @ac_token ||= client.auth_code.get_token(verifier, {:redirect_uri => callback_url}.merge(token_params.to_hash(:symbolize_keys => true)))
      end

      def callback_phase
        if request.params['error'] || request.params['error_reason']
          raise CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri'])
        end

        self.access_token = build_access_token
        self.access_token = access_token.refresh! if access_token.expired?
        @openid = request.params["openid"]
        @openkey = request.params["openkey"]

        super
      rescue ::OAuth2::Error, CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::MultiJson::DecodeError => e
        fail!(:invalid_response, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      end

      def raw_info
        @raw_info ||= access_token.get("/api/user/info", params: {
          openid: @openid,
          oauth_consumer_key: access_token.client.id,
          access_token: access_token.token,
          oauth_version: '2.a'
        }, parse: :json).parsed
      end
    end
  end
end
