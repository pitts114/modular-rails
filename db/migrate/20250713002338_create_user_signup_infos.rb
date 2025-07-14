class CreateUserSignupInfos < ActiveRecord::Migration[8.0]
  def change
    create_table :user_signup_infos, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :email, null: false
      t.string :phone_number

      t.timestamps
    end

    add_index :user_signup_infos, :email, unique: true
  end
end
