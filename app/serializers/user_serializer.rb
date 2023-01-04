class UserSerializer
  include JSONAPI::Serializer
  attributes *[
    :name,
    :email,
    :phone,
    :company_id,
    :department_id
  ]
end
