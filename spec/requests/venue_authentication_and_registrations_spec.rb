require 'spec_helper'

describe 'AUTHENTICATION' do

  subject { page }

  describe 'Venue Registration' do
    before { visit new_venue_registration_path }

    it { should have_content 'Sign up'}

    describe 'with valid information' do
      before do
        fill_in 'venue_name',              with: 'Caprice'
        fill_in 'venue_zipcode',           with: 'v7s1a1'
        fill_in 'venue_country',           with: 'Canada'
        fill_in 'venue_state',             with: 'BC'
        fill_in 'venue_city',              with: 'Vancouver'
        fill_in 'venue_address_line_one',  with: '123 Granville Street'
        fill_in 'venue_age_requirement',   with: '18'
        fill_in 'venue_email',                   with: 'Caprice@example.com'
        fill_in 'venue_password',                with: 'Subway123'
        fill_in 'venue_password_confirmation',   with: 'Subway123'

        click_button 'Sign up'
      end

      it { should have_link 'Dashboard'}
      it { should have_link 'sign out'}

    end

    describe 'with invalid information' do
      # TODO test out validations
    end


  end

  describe 'Login' do
    before {visit new_venue_session_path}

    it {should have_content 'Sign in'}

    describe 'with invalid credentials' do
      before { click_button 'Sign in'}
      it { should have_link 'sign in'}
    end

    describe 'with valid credentials' do
      let(:venue) {FactoryGirl.create(:venue)}
      before do 
        fill_in 'Email',    with: venue.email
        fill_in 'Password', with: 'LabasVakaras'
        click_button 'Sign in'
      end

      it { should have_link 'sign out'}
      it { should have_link 'Dashboard'}

      describe 'and sign out' do
        before { click_link 'sign out'}
        it {should have_link('sign in')}
      end
    end

    # TODO Write some tests for authorization to make sure malicious
    #      users cant access resources they're not allowed for critical
    #      controller actions.

  end
end
