require "spec_helper"

describe BetaSignupUsersController do
  describe "routing" do

    it "routes to #index" do
      get("/beta_signup_users").should route_to("beta_signup_users#index")
    end

    it "routes to #new" do
      get("/beta_signup_users/new").should route_to("beta_signup_users#new")
    end

    it "routes to #show" do
      get("/beta_signup_users/1").should route_to("beta_signup_users#show", :id => "1")
    end

    it "routes to #edit" do
      get("/beta_signup_users/1/edit").should route_to("beta_signup_users#edit", :id => "1")
    end

    it "routes to #create" do
      post("/beta_signup_users").should route_to("beta_signup_users#create")
    end

    it "routes to #update" do
      put("/beta_signup_users/1").should route_to("beta_signup_users#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/beta_signup_users/1").should route_to("beta_signup_users#destroy", :id => "1")
    end

  end
end
