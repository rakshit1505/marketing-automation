module CreateLead

  def self.iterate_lead(leads_arr, start_index)
    @errors = []
    @leads = []
    @valid_leads_arr = []
    finding_duplicate_rows(leads_arr, start_index)
    leads_arr.each.with_index(start_index) do |lead, index|
    leads_params(lead)
      initialize_record(ind) if @rep_params[:id].nil? && @errors.blank?
      update_record(ind) if @rep_params[:id].present? && @errors.blank?
    end

    if @errors.present?
      return {errors: @errors}
    else
      @valid_leads_arr.map(&:save)
      return {leads: @leads}
    end
  end

  def self.finding_duplicate_rows(leads_arr, start_index)
    leads_arr.each.with_index(ind).group_by(&:first).inject({}) do |result, (val, group)|
      next result if group.length == 1
      @errors << "Row #{group.map {|pair| pair[1]}} :- contains same data."
    end
  end

  def self.leads_params(lead)
    if lead.class == Hash
      @lead_params = lead
    else
      @lead_params = lead.permit(:id, :first_name, :last_name, :email_id, :phone_number, :company_id, :title, :lead_source_id, :lead_status_id, :industry, :company_size, :website, :address_id, :lead_rating_id, :user_id)
    end
  end

  def self.initialize_record(ind)
    (@start_date..@end_date).each do |date|
      rep_schedule = RepSchedule.find_by(@rep_params.except(:start_date, :end_date, :lunch_start_time, :lunch_end_time).merge(date: date.in_time_zone))
      if rep_schedule.present?
        error_msg = "Row #{ind} :- Rep Schedule with following data already exist.".delete('\\"')
        @errors << error_msg unless @errors.include?(error_msg)
      else
        rep_schedule = RepSchedule.new(@rep_params.except(:start_date, :end_date).merge(date: date.in_time_zone))
        if rep_schedule.valid?
          @valid_rep_schedules_arr << rep_schedule
          @reps << rep_schedule
        else
          error_msg = "Row #{ind} :- Rep Schedule contains following errors :- #{rep_schedule.errors.full_messages}".delete('\\"')
          @errors << error_msg unless @errors.include?(error_msg)
        end
      end
    end
  end

  def self.update_record(ind)
    find_rep_schedule(ind)
    if @errors.empty?
      rep_schedule_exist = RepSchedule.find_by(@rep_params.except(:id, :start_date, :end_date, :lunch_start_time, :lunch_end_time))
      if rep_schedule_exist.present? && rep_schedule_exist&.id != @rep_schedule.id
        error_msg = "Row #{ind} :- Rep Schedule with following data already exist.".delete('\\"')
        @errors << error_msg unless @errors.include?(error_msg)
      else
        if @rep_schedule.update(@rep_params)
          @reps << @rep_schedule
        else
          error_msg = "Row #{ind} :- Rep Schedule contains following errors :- #{@rep_schedule.errors.full_messages}".delete('\\"')
          @errors << error_msg unless @errors.include?(error_msg)
        end
      end
    end
  end

  def self.find_rep_schedule(ind)
    @rep_schedule = RepSchedule.find_by_id(@rep_params[:id])  
    @errors << "Row #{ind} :- No such Rep Schedule found with given ID." if @rep_schedule.nil?
  end
end