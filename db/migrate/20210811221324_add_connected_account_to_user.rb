class AddConnectedAccountToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :connected_account, :boolean, default: false
  end
end
