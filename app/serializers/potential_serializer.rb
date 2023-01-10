class PotentialSerializer
  include JSONAPI::Serializer
  attributes *[
    :outcome,
    :status,
    :lead_id,
    :user_id
  ]
end
