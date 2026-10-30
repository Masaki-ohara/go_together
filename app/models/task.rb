class Task < ApplicationRecord
  belongs_to :schedule, optional: true
  belongs_to :user, optional: true
end
