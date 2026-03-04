class Interview < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy
  has_many :messages, through: :chats

  has_one_attached :cv

  STATUSES = %w[pending active completed].freeze

  validates :job_title, presence: true
  validates :job_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "doit être une URL valide" }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }

  scope :completed, -> { where(status: "completed") }
  scope :active,    -> { where(status: "active") }
end
