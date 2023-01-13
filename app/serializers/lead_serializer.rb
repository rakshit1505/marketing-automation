class LeadSerializer
  include JSONAPI::Serializer
  attributes *[
    :first_name,
    :last_name,
    :email,
    :phone_number,
    :company_id,
    :title,
    :lead_source_id,
    :lead_rating_id,
    :industry,
    :company_size,
    :website,
    :address_id
  ]
end
