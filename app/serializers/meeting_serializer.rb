class MeetingSerializer
  include JSONAPI::Serializer
  attributes *[
    :title,
    :type_of_meeting,
    :is_online,
    :duration,
    :user_id,
    :description,
    :reminder,
    :agenda,
    :status
  ]
end
