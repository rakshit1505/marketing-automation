class NoteSerializer
  include JSONAPI::Serializer
  attributes *[
    :title,
    :description,
    :lead_id,
    :user_id,
    :attachment_id
  ]
end
