class User < ActiveRecord::Base
  has_one :subscription, dependent: :destroy
  has_one :plan, through: :subscription

  has_secure_password
  before_save { self.email = email.downcase }
  before_create :generate_reset_token

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: EMAIL_REGEX, message: "invalid format" }

  validates :password, 
    presence: true,
    length: { minimum: 6, maximum: 20 },
    allow_nil: true

  def has_subscription?
    !subscription.nil?
  end

  def refresh_reset_token
    generate_reset_token()
    save()
  end

  def generate_reset_token
    self.reset_token = loop do
      reset_token = SecureRandom.urlsafe_base64(64, false)
      break reset_token unless User.exists?(reset_token: reset_token)
    end
  end
end