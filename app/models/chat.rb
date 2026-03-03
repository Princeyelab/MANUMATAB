class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :interview
  has_many :message
end
