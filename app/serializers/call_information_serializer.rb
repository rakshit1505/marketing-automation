class CallInformationSerializer
  include JSONAPI::Serializer
  attributes *[
    :call_owner,
    :subject,
    :reminder,
    :status,
    :start_time,
    :user_id,
    :lead_id,
    :call_type_id
  ]
end
