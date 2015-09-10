class Domain
  def self.matches?(request)
    request.domain.present? && (request.domain.include? "herokuapp.com" or request.domain.include? "localhost")
  end
end