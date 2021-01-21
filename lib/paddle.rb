# paddle endpoint for receiving webhooks
# https://developer.paddle.com/webhook-reference/intro
module Paddle
  def react_to_hook(params)
    verify_hook(params) do
      email                 = params[:email]
      alert_name            = params[:alert_name]
      next_bill_date        = params[:next_bill_date] # 2021-01-18 
      status                = params[:status] # active/past_due/paused/deleted
      subscription_id       = params[:subscription_id]
      subscription_plan_id  = params[:subscription_plan_id] # plan_id
      cancel_url            = params[:cancel_url]
      cancellation_ef_date  = params[:cancellation_effective_date] # subscription should work till this date
      attempt_number        = params[:attempt_number] # retry payment count
      
      user = User.find_by(email: email)
      plan = Plan.find_by(paddle_product_id: subscription_plan_id)
      subscription = user.subscription
      
      case alert_name
      when "subscription_created"
        refresh_token = refresh_token(user, next_bill_date, subscription_id, subscription_plan_id)
        till = Time.parse(next_bill_date).to_i

        if subscription
          subscription.update!(plan: plan, 
                              refresh_token: refresh_token, 
                              expires_at: till, 
                              cancel_url: cancel_url)
        else
          Subscription.create(user: user, 
                              plan: plan, 
                              refresh_token: refresh_token, 
                              expires_at: till, 
                              cancel_url: cancel_url)          
        end
        
      # when "subscription_updated"
        # user has to cancel subscription first to change plan so we don't use this hook
      when "subscription_cancelled"
        if subscription && subscription.is_paused
          subscription.destroy()
        else
          refresh_token = 
            refresh_token(user, cancellation_ef_date, subscription_id, subscription_plan_id)
          till = Time.parse(cancellation_ef_date).to_i
          subscription.cancel(refresh_token, till)
        end        
      when "subscription_payment_succeeded"
        refresh_token = 
          refresh_token(user, next_bill_date, subscription_id, subscription_plan_id)
        till = Time.parse(next_bill_date).to_i
        subscription.renew(refresh_token, till)
      when "subscription_payment_failed" 
        subscription.pause() if attempt_number.to_i > 1
      when "subscription_payment_refunded"
        subscription.destroy()
      else
        
      end
    end
  end

  def verify_hook(data)
    public_key = File.read("./keys/pub.key")

    signature = Base64.decode64(data['p_signature'])
    data.delete('p_signature')
    data.each {|key, value|data[key] = String(value)}
    data_sorted = data.sort_by{|key, value| key}
    data_serialized = PHP.serialize(data_sorted, true)
    digest    = OpenSSL::Digest::SHA1.new
    pub_key   = OpenSSL::PKey::RSA.new(public_key).public_key
    verified  = pub_key.verify(digest, signature, data_serialized)

    yield if verified
  end
end