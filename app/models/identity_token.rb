class IdentityToken
	attr_reader :user_id, :nonce, :expires_at

	def initialize(options = {})
		# User ID is your backend's user identifier
		@user_id = options[:user_id]
		# Nonce must be obtatined from SDK
		@nonce = options[:nonce]
		# Layer does not enforces an expiration time, it is up to your backend
		@expires_at = (options[:expires_at] || 2.weeks.from_now)
		# Constructing the claim
		@jwt = JSON::JWT.new(claim)
		# Constructing the header
		@jwt.header['typ'] = 'JWS'
		@jwt.header['cty'] = 'layer-eit;v=1'
		@jwt.header['kid'] = layer_key_id
		@jwt.header['alg'] = 'RS256'
	end

	def to_s
		@jwt.sign(private_key, :RS256).to_s
	end
	def layer_key_id
		# ENV['LAYER_KEY_ID']
		ENV['LAYER_AUTH_PUB_KEY']
	end
	def layer_provider_id
		# ENV['LAYER_PROVIDER_ID']
		ENV['LAYER_APP_ID']
	end
	
	private
		def claim
			{
				iss: layer_provider_id,
				prn: user_id.to_s,
				iat: Time.now.to_i,
				exp: expires_at.to_i,
				nce: nonce
			}
		end
		def private_key
			OpenSSL::PKey::RSA.new(ENV['LAYER_PRIVATE_KEY'])
		end
end