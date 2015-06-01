class Domain
  def self.matches?(request)
  	puts "REQQQ"
  	puts request.domain.inspect
  	puts request.env["SERVER_NAME"]
    request.domain.present? && (request.domain.include? "purpleoctopus-staging" or request.domain.include? "localhost")
  end
end