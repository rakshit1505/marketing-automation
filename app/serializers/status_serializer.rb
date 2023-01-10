class StatusSerializer
  include JSONAPI::Serializer
  attributes *[
    :name
  ]
end
