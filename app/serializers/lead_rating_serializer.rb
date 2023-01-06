class LeadRatingSerializer
  include JSONAPI::Serializer
  attributes *[
    :name
  ] 
end
