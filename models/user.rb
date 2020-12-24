class User < ActiveRecord::Base
  has_secure_password
  before_create :pause
  before_save { self.email = email.downcase }

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: EMAIL_REGEX, message: "invalid format" }

  validates :password, 
    presence: true,
    length: { minimum: 6, maximum: 20 },
    allow_nil: true

  def active?
    self.status == "active"
  end

  def activate
    self.status = "active"    
  end

  def pause
    self.status = "inactive"   
  end
end