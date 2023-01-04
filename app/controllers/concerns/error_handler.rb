module ErrorHandler
    def format_activerecord_errors(errors)
        result = []
        errors.each do |attribute, error|
            result << { attribute => error }
        end
        result
    end

    def item_not_found(type, id)
      render json: {
          errors: [{
          "#{type}" => "Record with id= #{id} not found"
          }]
      },
      status: :unprocessable_entity
    end
end
