class DepartmentSerializer
  include JSONAPI::Serializer
  attributes *[
    :name
  ] 
end
