class AddShibbolethAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :group, :string
    add_column :users, :umbcusername, :string
    add_column :users, :displayName, :string
    add_column :users, :umbcDepartment, :string
    add_column :users, :mail, :string
  end
end
