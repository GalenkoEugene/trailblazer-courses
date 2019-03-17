class CreateUserInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :user_invitations do |t|
      t.string :email, null: false
    end
  end
end
