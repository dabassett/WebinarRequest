class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :name
      t.string :requester
      t.string :requester_email
      t.date :date
      t.time :start_time
      t.time :end_time
      t.string :sponsor
      t.string :cost
      t.boolean :discount
      t.string :discount_owner
      t.text :description
      t.text :url
      t.boolean :approved, default: false
      t.boolean :reviewed, default: false

      t.timestamps
    end
  end
end
