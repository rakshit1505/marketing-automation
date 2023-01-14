class DownloadTemplateService
  def excel_template
    data = nil
    Axlsx::Package.new do |p|
     p.workbook.add_worksheet(name: "Leads") do |ws|
        ws.add_row ["Lead Owner","First Name","Last Name","Email","Contact","Company","Lead Source","Lead Status","Industry","Company Size","Website","street","city","state","zip_code","country"]
      end
      data = p
    end
    return data
  end
end

