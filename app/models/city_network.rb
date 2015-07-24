class CityNetwork < ActiveRecord::Base
  

  def self.sync_gimbal
  	require 'json'
  	require 'httparty'

  	response = HTTParty.get("https://manager.gimbal.com/api/geofences", :headers => { "Authorization" => "Token token=b99c16b7b8b27de4361b1c51a58c1c3a"})
  	header = response.header
  	if header and header['status'] == '200 OK'
  		parsed_json = response.parsed_response
  		if parsed_json and !parsed_json['geofences'].blank?

  			parsed_json['geofences'].each do |place|
  				if place['placeAttributes'] and place['placeAttributes']['type']
	  				type = place["placeAttributes"]["type"].titleize
	  			else
	  				type = ""
	  			end
	  			if type == "Region"
	  				name = place["name"]
	  				if CityNetwork.find_by_name(name).nil?
	  					CityNetwork.create!(:name => name)
	  				end
	  			end
  			end
  		end
  	end
  end
end