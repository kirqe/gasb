class Subscription < ActiveRecord::Base

  def self.validate(plan_id, user)
    # https://developer.paddle.com/api-reference/subscription-api/users/listusers
    url = URI("https://vendors.paddle.com/api/2.0/subscription/users")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request.body = "vendor_id=#{ENV['paddle_vendor_id']}&vendor_auth_code=#{ENV['paddle_auth_code']}&plan_id=#{plan_id}&state=active"      
    response = http.request(request)
    
    has_found = JSON.parse(response.body)["response"].find {|u| u["user_email"] == user.email}
    if has_found 
      user.activate
      user.save
      return true
    else
      user.pause
      user.save
      return false
    end
  end
end