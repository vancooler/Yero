class UserRegistration
  attr_reader :user
  def initialize(user_params)
    @user = User.new(user_params)
    p @user 
    p "user has been initialized"
    p @user.inspect
  end
  def create
    create_key
    @user.save
    create_layer_account
  end

  private
    def create_key
      @user.key = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(key: random_token)
      end
    end
    def create_layer_account
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
      require "base64"

      data = [{ 
        "id" => @user.key,
        typ: "JWS",
        alg: "RS256",
        cty: "layer-eit;v=1",
        kid:ENV['LAYER_AUTH_PUB_KEY']
        }].to_json
      claim=[{
          iss: ENV['LAYER_APP_ID'],
          prn: @user.key,
          iat: Time.now.to_i,
          exp: (Time.now + 20.years).to_i,
          nce: "@user.nonce"
        }].to_json
      enc_data = Base64.urlsafe_encode64(data)
      enc_claim = Base64.urlsafe_encode64(claim)
      encoded_content = enc_data + "." + enc_claim
      Rails.logger.info "GGGGGG: " + @user.nonce
      #Rails.logger.info "HHHHHHHHH:" + encoded_content

# private_key = %Q(
# -----BEGIN RSA PRIVATE KEY-----
# MIICWwIBAAKBgFuwNhDvT1QsxCiIaC2zLuc4mHcVrQgmcyEkLgX8pf22wTblFRMy
# ivscGyCZ2IkAHxwCdea8M1FdTMEuW3k52tkpXl3KZVx9E+DygqAJOBycaoxZqaVQ
# WnXAdKJupQbtJZGjJW0bGt/vPwibnc/YwWwoK4l/YhVYzr+2LKijXNX/AgMBAAEC
# gYA4Psl77AIDBg8zOjKGTlQofXxyGPbzd/rKStJ807bUBCdU0IT0KN4/Gse9YQMH
# T+7FlPDUoYDtmcl6/EAbBpWsQQql3qFVTBY8hf1bNuQwu9zkw3bhAQLYXeRorlie
# aNVrTqquwn/jc+poBhXgYyCeYVwDpzRvySTVU4YFUzmDgQJBALc71uReb2cdvSsC
# KZDVw3YQaHtau02vlGiqitkzsTzCsk9d5J4kLhkVzWEz/167ny34Sda1bspwpCGO
# zQbHcL8CQQCAGY4xswamPLCXw5iRT6LRNLAR3QGIiUnOc+Bbv+T3I35xQWhs+gTX
# L+lUjAS/usrh7I+Y7tR7hy7Dm6FQXqrBAkAXQkpJ3M7pWPYNQo4CK5BPKVAJ8H98
# IgCFtLhBT/V8j/5QYsvFYzRSzNiwMQiGfux6ylydG5S/r8K128mcxa5DAkB4yqBA
# 0RXGD5hdozzsWPGo4EverE3T19FW8gFvwsU/HaMPXKQBjsiduToGVXns6VCCNTU6
# +oo2aUR5gvlb9ciBAkEAil5BP/x9GgL/xOcKWI/rdGTXsvVc6OZz8onrSeJpQX7f
# 6VPJFubF28fiWGW4u7yKhMonmNaUSLCiR/wBRpHFSw==
# -----END RSA PRIVATE KEY-----
# ).delete!("\n")
#       JWT.encode(data, private_key, "RS256", {"kid" => ENV['LAYER_APP_ID']})
#       public_key = OpenSSL::PKey::EC.new("8ef75be4-2182-11e4-b157-301601003ad4")
#       token = JWT.encode(data, private_key)
#       RestClient.put( "https://layer.com/users/"+ENV['LAYER_APP_ID']+"/token",
#                           {
#                             access_token: token
#                           }

#                                   # "jws_claim" =>{
#                                   #   iss: ENV['LAYER_APP_ID'],
#                                   #   prn: @user.key,
#                                   #   uat: Time.now,
#                                   #   exp: Time.now + 20.years
#                                   # }
#                               # }
#                         )
#       @user.layer_id = token

    end
end