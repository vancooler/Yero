require 'spec_helper'

describe "EarlyVenues" do
  describe "GET /early_venues" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get early_venues_path
      response.status.should be(200)
    end
  end
end
