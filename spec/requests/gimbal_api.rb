require 'spec_helper'
# require 'sidekiq/testing'
# Sidekiq::Testing.disable!

describe "Gimbal API" do

  describe "Authenication with key" do
    before do
      @response = RestClient.get('https://manager.gimbal.com/api/', 
         
          :Authorization => ENV['GIMBAL_API_KEY']
        )
    end
    it { expect(@response.code).to be == 200 }
  end
end