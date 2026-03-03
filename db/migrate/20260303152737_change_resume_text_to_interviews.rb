class ChangeResumeTextToInterviews < ActiveRecord::Migration[8.1]
  def change
    rename_column :interviews, :resume_text, :summary
  end
end
