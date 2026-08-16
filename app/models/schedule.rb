# app/models/schedule.rb
class Schedule < ApplicationRecord
  belongs_to :group
  has_many :schedule_items, dependent: :destroy
  
  # ⭕️ 親(Schedule)を保存するときに、子(schedule_items)も一緒に保存・削除できるようにする設定
  accepts_nested_attributes_for :schedule_items, allow_destroy: true
end
