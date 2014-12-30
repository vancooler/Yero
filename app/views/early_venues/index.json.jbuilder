json.array!(@early_venues) do |early_venue|
  json.extract! early_venue, :id, :username, :city, :job_title, :phone, :email, :venue_name
  json.url early_venue_url(early_venue, format: :json)
end
