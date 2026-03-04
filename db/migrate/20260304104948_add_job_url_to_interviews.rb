class AddJobUrlToInterviews < ActiveRecord::Migration[8.1]
  def change
    add_column :interviews, :job_url, :string
  end
end
