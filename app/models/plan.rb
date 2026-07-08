class Plan < ApplicationRecord
    belongs_to :group, optional: true
    has_many :plan_items, dependent: :destroy
    has_many :votes, dependent: :destroy
    has_many :voted_users, through: :votes, source: :user
    validates :title, presence: true
    validates :location, presence: true
    validates :budget, presence: true
    accepts_nested_attributes_for :plan_items, allow_destroy: true
end
