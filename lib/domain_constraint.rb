class DomainConstraint
  def initialize(domain)
    @domains = [domain].flatten
  end

  def matches?(request)
  	puts "REEEQ"
  	puts request.env['SERVER_NAME']
    @domains.include? request.env['SERVER_NAME']
  end
end