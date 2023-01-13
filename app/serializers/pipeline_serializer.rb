class PipelineSerializer
  include JSONAPI::Serializer
  attributes *[
    :account_name,
    :score,
    :journey,
    :probability,
    :expected_revenue,
    :user_id,
    :lead_source_id
  ]
end
