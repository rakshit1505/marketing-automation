class LeadStatusSerializer
  include JSONAPI::Serializer
  attributes *[
    :name
  ] 
end
