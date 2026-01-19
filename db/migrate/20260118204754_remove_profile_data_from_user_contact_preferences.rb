class RemoveProfileDataFromUserContactPreferences < ActiveRecord::Migration[8.0]
  def change
    remove_column :user_contact_preferences, :email, :string
    remove_column :user_contact_preferences, :phone_number, :string
  end
end
