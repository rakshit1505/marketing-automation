class CompanySerializer
  include JSONAPI::Serializer
  attributes *[
    :last_name,
    :website,
    :social_media_handle
  ]
end
