class DealSerializer
  include JSONAPI::Serializer
  attributes *[
    :kick_off_date,
    :sign_off_date,
    :term,
    :tenure,
    :description,
    :status,
    :potential_id,
    :user_id
  ]
end
