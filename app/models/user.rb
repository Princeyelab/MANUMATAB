class User < ApplicationRecord
  has_many :chats
  has_many :messages
  has_many :interviews
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_one_attached :cv_file
  
  # Optionnel : validation du format
  validates :cv_file, content_type: ['application/pdf'], 
                     size: { less_than: 5.megabytes }
                     
end
