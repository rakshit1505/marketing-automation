class CallTypeSerializer
  include JSONAPI::Serializer
  attributes *[
    :name
  ]
end
