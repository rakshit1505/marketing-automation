class Lead < ApplicationRecord
   require "create_lead.rb"

  belongs_to :user, optional: true
  belongs_to :lead_source, optional: true
  belongs_to :lead_rating, optional: true
  has_one :potential, dependent: :destroy
  # has_one :deal, through: :potential
  has_one :lead_address, dependent: :destroy
  has_many :tasks
  has_many :statuses, as: :statusable
  belongs_to :addresses, optional: true

  validates :first_name, :last_name, presence: true
 
   def self.import_file_data(file)
    start_index = 2
    leads_arr = []
    @errors = []
    file_ext = File.extname(file.original_filename)
    begin
      spreadsheet = Roo::Excelx.new(file.path) if file_ext == '.xlsx'
      spreadsheet = Roo::Excel.new(file.path) if file_ext == '.xls'
    rescue Zip::Error
      return {errors: 'Unknown file'}
    end
    
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      assign_values(row)
      validate_row(row, i)
      leads_arr << get_row_attributes(row) if @errors.blank?
    end

    if leads_arr.blank? || @errors.present?
      return {errors: @errors.present? ? @errors : 'No Data Present in the File.'}
    else
      CreateLead.iterate_lead(leads_arr, start_index)
    end
  end

  def self.validate_row(row, ind)
    @errors << "Row #{ind} :- Please select a Lead Owner." unless @lead_owner.present?
    @errors << "Row #{ind} :- Please select a First Name." unless @first_name.present?
    @errors << "Row #{ind} :- Please select a Last Name." unless @last_name.present?
    @errors << "Row #{ind} :- Please select a Email." unless @email.present?
    @errors << "Row #{ind} :- Please select a Contact." unless @contact.present?
    @errors << "Row #{ind} :- Please select a Company." unless @company.present?
    @errors << "Row #{ind} :- Please select a Lead Source." unless @lead_source.present?
    @errors << "Row #{ind} :- Please select a Lead Status." unless @lead_status.present?
    @errors << "Row #{ind} :- Please select a Industry." unless @industry.present?
    @errors << "Row #{ind} :- Please select a Company Size." unless @company_size.present?
    @errors << "Row #{ind} :- Please select a Website." unless @website.present?
    @errors << "Row #{ind} :- Please select a street." unless @street.present?
    @errors << "Row #{ind} :- Please select a City." unless @city.present?
    @errors << "Row #{ind} :- Please select a State." unless @state.present?
    @errors << "Row #{ind} :- Please select a Zip Code." unless @zip_code.present?
    @errors << "Row #{ind} :- Please select a Country." unless @country.present?
   end 

  def self.get_row_attributes(row)
    {
      first_name: @first_name,
      last_name: @last_name,
      email_id: @email,
      phone_number: @contact,
      company_id: Company.find_or_create_by(name: @company)&.id,
      title: "title",
      lead_source_id: LeadSource.find_or_create_by(name: @lead_source),
      lead_status_id: Status.find_or_create_by(name: @status)&.id,
      industry: @industry,
      company_size: @company_size,
      website: @website,
      address_id: Address.find_or_create_by(street:@street,city:@city,state:@state,zip_code:@zip_code,country:@country)&.id,
      lead_rating_id: 0,
      user_id: User.find_by(full_name: @lead_owner)&.id
    }
  end

  def self.assign_values(row)
    @lead_owner = row['Lead Owner']
    @first_name = row['First Name']
    @last_name = row['Last Name']
    @email = row['Email']
    @contact = row['Contact']
    @company = row['Company']
    @lead_source = row['Lead Source']
    @lead_status = row['Lead Status']
    @industry = row['Industry']
    @company_size = row['Company Size']
    @website = row['Website']
    @street = row["street"]
    @city = row["city"]
    @state = row["state"]
    @zip_code = row["zip_code"]
    @country = row["country"]
  end
end
