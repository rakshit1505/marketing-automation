class AuditObserver < ActiveRecord::Observer
  observe :lead, :potential, :deal

  def after_create(auditable)
    debugger
    AUDIT_LOG.info "[#{username}][ADD][#{auditable.class.name}][#{auditable.id}]:#{auditable.inspect}"
  end

  def before_update(auditable)
    AUDIT_LOG.info "[#{username}][MOD][#{auditable.class.name}][#{auditable.id}]:#{auditable.changed.inspect}"
  end

  def before_destroy(auditable)
    AUDIT_LOG.info "[#{username}][DEL][#{auditable.class.name}][#{auditable.id}]:#{auditable.inspect}"
  end

  def username
    (Thread.current['username'] || "UNKNOWN").ljust(30)
  end
end