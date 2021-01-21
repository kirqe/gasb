class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :plan

  def renew(refresh_token, expires_at)
    update!(refresh_token: refresh_token, expires_at: expires_at, is_paused: false)
  end

  def cancel(refresh_token, expires_at)
    update!(refresh_token: refresh_token, expires_at: expires_at, cancel_url: nil, is_paused: false)
  end

  def pause
    update!(is_paused: true)
  end

  def is_cancelled?
    !!cancel_url.nil?
  end

  def is_active?
    (expires_at > Time.now.to_i) && !is_paused
  end
end