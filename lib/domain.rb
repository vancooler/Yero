class Domain
  def self.matches?(request)
  	puts "REQQQ"
  	puts request.inspect
    request.domain.present? && (request.domain.include? "purpleoctopus-staging" or request.domain.include? "localhost")
  end
end