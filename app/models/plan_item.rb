class PlanItem < ApplicationRecord
  belongs_to :plan
  validates :content, presence: true, unless: :marked_for_destruction?
end
