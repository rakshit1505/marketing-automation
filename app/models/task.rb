class Task < ApplicationRecord

  belongs_to :task_owner, class_name: 'User', foreign_key: :task_owner, optional: true
end
