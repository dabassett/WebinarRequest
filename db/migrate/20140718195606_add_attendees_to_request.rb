class AddAttendeesToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :attendees, :string
  end
end
