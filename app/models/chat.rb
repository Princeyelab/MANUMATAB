class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :interview

  has_many :messages, dependent: :destroy
end
