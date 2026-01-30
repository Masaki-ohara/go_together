class Plan < ApplicationRecord
    has_many :plan_items, dependent: :destroy
    validates :title, presence: true
end
