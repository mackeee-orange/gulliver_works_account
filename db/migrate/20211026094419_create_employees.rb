class CreateEmployees < ActiveRecord::Migration[6.0]
  def change
    create_table :employees, id: :uuid do |t|
      t.string :email, null: false, comment: 'メールアドレス'
      t.integer :email_verification_status, null: false, default: 0, comment: 'メールの認証状況'
      t.string :email_verification_token
      t.string :last_notification_read_at

      t.timestamps
    end
  end
end
