class CreateInterviewSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :interviews do |t|
      t.references :user, null: false, foreign_key: true
      t.string :job_title, null: false
      t.text :job_description
      t.text :resume_text
      t.string :status, null: false, default: "pending"
      t.text :feedback

      t.timestamps
    end
  end
end
