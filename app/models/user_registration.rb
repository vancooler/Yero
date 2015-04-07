class UserRegistration
  attr_reader :user
  def initialize(user_params)
    @user = User.new(user_params)
    p "PARAMS:" 
    p user_params
    p @user 
    p "user has been initialized"
    p @user.inspect
  end
  def create
    create_key
    @user.last_active = Time.now
    @user.save
    if @user.default_avatar.nil?
      @user.account_status = 0  # inactive without avatar
    else
      @user.account_status = 1  # active with avatar
    end
    @user.save
    # create_layer_account
  end

  private
    def create_key
      @user.key = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(key: random_token)
      end
    end

    def create_layer_account
      #####################################################################
      #
      # If the Chat token created on the phone side, just set it in singup
      # param "layer_id"
      #
      # if the parameters have no token but have nonce like Layer, 
      # generate token and save it
      #
      #####################################################################

      if @user.layer_id.nil? and @user.nonce.present?
        @user.layer_id = "pending"
        # @user.layer_id = "Not Available"
        # cert = AWS::S3.new.buckets[ENV['S3_BUCKET_NAME']].objects['private/layer/layer.crt'].read
        # key = AWS::S3.new.buckets[ENV['S3_BUCKET_NAME']].objects['private/layer/layer.key'].read

        # require "net/https"
        # require "uri"
        # require "json"

        # uri = URI "https://api-beta.layer.com/users"
        # http = Net::HTTP.new(uri.host, uri.port)
        # http.use_ssl = true
        # http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        # http.key = OpenSSL::PKey::RSA.new(key)
        # http.cert = OpenSSL::X509::Certificate.new(cert)

        # request = Net::HTTP::Post.new(uri.request_uri)

        # data = [{ "id" => @user.id, "access_token" => @user.key }].to_json
        # request.body = data
        # request["Content-Type"] = "application/json"

        # response = http.request(request)
        # @user.layer_id = JSON.parse(response.body)["users"][0]["layer_id"]

        # save
        # enc_data = Base64.urlsafe_encode64(data)
        # enc_claim = Base64.urlsafe_encode64(claim)
        # encoded_content = enc_data + "." + enc_claim
        # Rails.logger.info "GGGGGG: " + @user.nonce
        require "base64"

        if Rails.env == "development"
          claim={
              iss: '72767b32-1f2d-11e4-b632-09c700006127', #ENV['LAYER_APP_ID'],
              prn: @user.key,
              iat: Time.now.to_i,
              exp: (Time.now + 20.years).to_i,
              nce: @user.nonce
            }
        else
          claim={
              iss: ENV['LAYER_APP_ID'],
              prn: @user.key,
              iat: Time.now.to_i,
              exp: (Time.now + 20.years).to_i,
              nce: @user.nonce
            }
        end
        layer_private_key = "MIICWwIBAAKBgHy9T7wGqCcrvPDkYysQT+yeAGAofuGsnfb92KrUmnWziazsFP1IuRFXZ3ISi0cH+YOzwooCU6g9f1jRgHfl29UB7v4DneUMcAnuA78XamIUcDSByBcLRtqmW/t+8s/POSzmz3GYkTn2q443rW+e25lSp+SL1KrBQue1gMkdWnUvAgMBAAECgYABXOAeIcR8iRHLX/NlaQw2fZNreYXJWWVwaV2QoDn/xzJd3UZtbfn3oojSyjkTUZb8RV5+u3/GesWFZuSMasp4CV8e8XB40pWYOXYu3s0FY0Qv3JlN/q7XUt44k+PgF0U6XxGFQ+FdzAxxRXwu7+A78Gbj8RSalCnkQDh2bZ5zQQJBAMAztdiRcOvyjsMlnipur5phbWgsVCalQPYzuxphEa6+fwvF7Swpfs8X8D+tSbkJMJ+ArPDbMPNym2ZQvXgvOVcCQQCmJQB1oGHfRLNIClhZtvtQBRQMUeU4tlXb8KxUrOwymY5JMt90C5nBO+el9fxm1VXhVko1PNDFEIHmh8TSnsPpAkB07AAnqvKC1p+6X1wEfCkfRT2FLdJTYBxQqc+ckIhtQT2QL+vD/cpCuVFRq105zzlhDqomK3Fv57xZVaytPC0pAkAReDSLKbkAy+159rSBgm78Y/xOq1HJ28o9XRoRsTkIvQKsCbBbOFkLa2wZFDtc6LOmBPe6j1F4VxsBjWcRqmX5AkEAplz5LeaZ17gEYugLUVKSy5PoGw16CQ+pkXrcswOuA2AE3qFh+txHMIre/cZfavYedxbvIhlWMSYfx33r1XPD3g=="
        private_key = OpenSSL::PKey::RSA.new(Base64.decode64(layer_private_key)) #ENV['LAYER_PRIVATE_KEY'])

        @jwt = JSON::JWT.new(claim)
        # Constructing the header
        @jwt.header['typ'] = 'JWS'
        @jwt.header['cty'] = 'layer-eit;v=1'
        if Rails.env == "development"
          @jwt.header['kid'] = '25611206-65e8-11e4-a3ec-e6f6000002da' #ENV['LAYER_AUTH_PUB_KEY']
        else
          @jwt.header['kid'] = ENV['LAYER_AUTH_PUB_KEY']
        end
        @jwt.header['alg'] = 'RS256'

        token = @jwt.sign(private_key, :RS256).to_s

        Rails.logger.info "HHHHHHHHH:" + token

  #       JWT.encode(data, private_key, "RS256", {"kid" => ENV['LAYER_APP_ID']})
  #       public_key = OpenSSL::PKey::EC.new("8ef75be4-2182-11e4-b157-301601003ad4")
  #       token = JWT.encode(data, private_key)
        @user.layer_id = token
        @user.save
        # RestClient.put( "https://layer.com/users/72767b32-1f2d-11e4-b632-09c700006127/token",
        #                     {
        #                       access_token: token
        #                     }
        #                   )

                                    # "jws_claim" =>{
                                    #   iss: ENV['LAYER_APP_ID'],
                                    #   prn: @user.key,
                                    #   uat: Time.now,
                                    #   exp: Time.now + 20.years
                                    # }
                                # }
        # logger.info response
      end
    end
end











