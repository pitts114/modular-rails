class CreateUserContactPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :user_contact_preferences, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.string :email
      t.string :phone_number
      t.boolean :email_notifications_enabled, default: true
      t.boolean :phone_notifications_enabled, default: true

      t.timestamps
    end

    add_index :user_contact_preferences, :user_id, unique: true
    add_foreign_key :user_contact_preferences, :users
  end
end
