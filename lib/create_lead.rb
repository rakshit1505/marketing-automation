module CreateLead

  def self.iterate_lead(leads_arr, start_index)
    @errors = []
    @leads = []
    @valid_leads_arr = []
    finding_duplicate_rows(leads_arr, start_index)
    leads_arr.each.with_index(start_index) do |lead, ind|
    leads_params(lead)
      initialize_record(ind) if @lead_params[:id].nil? && @errors.blank?
      update_record(ind) if @lead_params[:id].present? && @errors.blank?
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
      lead = Lead.find_by(@lead_params)
      if lead.present?
        error_msg = "Row #{ind} :- Lead with following data already exist.".delete('\\"')
        @errors << error_msg unless @errors.include?(error_msg)
      else
        lead = Lead.new(@lead_params)
        if lead.valid?
          @valid_leads_arr << lead
          @leads << lead
        else
          error_msg = "Row #{ind} :- Lead contains following errors :- #{lead.errors.full_messages}".delete('\\"')
          @errors << error_msg unless @errors.include?(error_msg)
        end
      end
    end
  end

  def self.update_record(ind)
    find_lead(ind)
    if @errors.empty?
      lead_exist = Lead.find_by(@lead_params)
      if lead_exist.present? && lead_exist&.id != @lead.id
        error_msg = "Row #{ind} :- Lead with following data already exist.".delete('\\"')
        @errors << error_msg unless @errors.include?(error_msg)
      else
        if @lead.update(@lead_params)
          @leads << @lead
        else
          error_msg = "Row #{ind} :- lead Schedule contains following errors :- #{@lead.errors.full_messages}".delete('\\"')
          @errors << error_msg unless @errors.include?(error_msg)
        end
      end
    end
  end

  def self.find_lead(ind)
    @lead = Lead.find_by_id(@lead_params[:id])  
    @errors << "Row #{ind} :- No such lead Schedule found with given ID." if @lead.nil?
  end
end