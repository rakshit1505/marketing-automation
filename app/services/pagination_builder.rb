class PaginationBuilder
    attr_accessor :page, :per_page, :limit, :offset

    def initialize(page, per_page)
        @page = build_page(page)
        @per_page = build_per_page(per_page)
    end

    def build_page(page)
        page = page.present? ? page.to_i : 1
        (page > 0) ? page : 1
    end

    def build_per_page(per_page)
        per_page = per_page.present? ? per_page.to_i : 10
        (per_page > 0) ? per_page : 10
    end

    def paginate
        offset = (@page - 1) * @per_page
        return @per_page, offset
    end

    def total_pages(total_count)
        (total_count / @per_page.to_f).to_f.ceil 
    end
end