class CreatePlans < ActiveRecord::Migration[6.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.string :note
      t.string :per
      t.decimal :price
      t.integer :paddle_product_id
      t.boolean :featured
    end
  end
end
