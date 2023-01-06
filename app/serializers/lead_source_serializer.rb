class LeadSourceSerializer
  include JSONAPI::Serializer
  attributes *[
    :name
  ] 
end
