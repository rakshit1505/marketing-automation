class LeadAddressSerializer
  include JSONAPI::Serializer
  attributes *[
    :street_address,
    :city,
    :state,
    :country,
    :zip_code,
    :lead_id
  ]
end
