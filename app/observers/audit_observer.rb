class AuditObserver < ActiveRecord::Observer
  observe :lead, :potential, :deal

  def after_create(auditable)
    Audit.create!(auditable_type:auditable.class.name,description: "Created a new #{auditable.class.name}",field_name: "All attributes",user_id: auditable&.current&.id)
  end

  def before_update(auditable)
    Audit.create!(auditable_type:auditable.class.name,description: "Modified attributes from #{auditable.class.name}",field_name: "#{auditable.changed.inspect}",user_id: auditable.current.id)
  end

  def before_destroy(auditable)
    Audit.create!(auditable_type:auditable.class.name,description: "Deleted attributes from #{auditable.class.name}",field_name: "#{auditable.changed.inspect}",user_id: auditable&.current&.id)
  end

end
