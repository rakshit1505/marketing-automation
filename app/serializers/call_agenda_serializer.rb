class CallAgendaSerializer
  include JSONAPI::Serializer
  attributes *[
    :objective,
    :description,
    :call_information_id
  ]
end
