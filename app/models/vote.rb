class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :plan
  
  validates :user_id, uniqueness: { scope: :plan_id, message: "はすでにこのプランに投票しています" }
end
