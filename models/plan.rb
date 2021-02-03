class Plan < ActiveRecord::Base
  has_one :subscription, dependent: :destroy
  has_one :user, through: :subscription
end