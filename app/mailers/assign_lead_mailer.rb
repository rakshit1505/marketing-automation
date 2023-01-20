class AssignLeadMailer < ApplicationMailer
  layout 'bootstrap-mailer'

  def assign_lead_mail(lead, current_user, from)
    @current_user = "#{current_user.try(:first_name)} #{current_user.try(:last_name)}"
    @lead_title = lead.title
    @assigned_lead_user = lead.user
    @content = from == 'create_lead' ? "Lead of '#{lead.try(:first_name)} #{lead.try(:last_name)}' has assigned to you" : "#{@current_user} has assigned lead of '#{lead.try(:first_name)} #{lead.try(:last_name)}' to you"

    mail(
        to: @assigned_lead_user.email,
        from: 'automation_marketing@protonshub.in',
        subject: 'Marketing Automation: Lead Assign' ) do |format|
        format.html { render 'assign_lead_mailer/assign_lead_mail' }
    end
  end
end
