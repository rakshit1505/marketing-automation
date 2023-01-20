class AssignLeadJob < ApplicationJob
  queue_as :mailers

  def perform(lead, current_user, from)
    AssignLeadMailer.assign_lead_mail(lead, current_user, from).deliver
  end
end
