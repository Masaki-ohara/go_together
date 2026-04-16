class Plan < ApplicationRecord
    belongs_to :group, optional: true
    has_many :plan_items, dependent: :destroy
    validates :title, presence: true
    validates :location, presence: true
    validates :budget, presence: true
    accepts_nested_attributes_for :plan_items, allow_destroy: true
end
