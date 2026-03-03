class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :interview_session
  has_many :message
end
