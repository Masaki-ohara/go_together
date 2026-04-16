class Group < ApplicationRecord
  before_create :share_token
  belongs_to :user
  has_many :plans, dependent: :destroy

  def share_token
    self.share_token = SecureRandom.hex(10)
  end
end
