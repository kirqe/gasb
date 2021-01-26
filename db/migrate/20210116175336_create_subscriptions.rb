class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :plan_id
      t.string :refresh_token
      t.integer :expires_at
      t.string :cancel_url
      t.string :update_url
      t.boolean :is_paused, default: false
    end
  end
end
