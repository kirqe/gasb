class Plan < ActiveRecord::Base
  has_one :subscription
  has_one :user, through: :subscription
end