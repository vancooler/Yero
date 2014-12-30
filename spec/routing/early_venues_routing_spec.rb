require "spec_helper"

describe EarlyVenuesController do
  describe "routing" do

    it "routes to #index" do
      get("/early_venues").should route_to("early_venues#index")
    end

    it "routes to #new" do
      get("/early_venues/new").should route_to("early_venues#new")
    end

    it "routes to #show" do
      get("/early_venues/1").should route_to("early_venues#show", :id => "1")
    end

    it "routes to #edit" do
      get("/early_venues/1/edit").should route_to("early_venues#edit", :id => "1")
    end

    it "routes to #create" do
      post("/early_venues").should route_to("early_venues#create")
    end

    it "routes to #update" do
      put("/early_venues/1").should route_to("early_venues#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/early_venues/1").should route_to("early_venues#destroy", :id => "1")
    end

  end
end
