class UserSerializer
  include JSONAPI::Serializer
  attributes *[
    :first_name,
    :last_name,
    :email,
    :phone,
    :company_id,
    :department_id
  ]
end
