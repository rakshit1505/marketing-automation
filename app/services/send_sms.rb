class SendSms
    attr_reader :to, :text_content
  
    def initialize(to, text_content)
      @to = to
      @text_content = text_content
    end
  
    def call
      client = Twilio::REST::Client.new
      client.messages.create({
        from: ENV["twilio_phone_number"],
        to: to,
        body: text_content
      })
    end
  
  end