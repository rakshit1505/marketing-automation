class TaskSerializer
  include JSONAPI::Serializer
  attributes *[
    :task_owner,
    :last_name,
    :due_date_time,
    :priority
  ]
end
