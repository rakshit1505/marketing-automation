class PotentialSerializer
  include JSONAPI::Serializer
  attributes *[
    :outcome,
    :status,
    :amount,
    :lead_id,
    :user_id,
    :company_id
  ]
end
