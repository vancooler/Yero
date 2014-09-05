include ApplicationHelper

def sign_in(user)
    visit signin_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: "foobar11"
    click_button "Sign in"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :be_a_valid_api_response do
    match do |json_response|
        json_response['version'] == '1.0' &&
            json_response['response']['status'] == 0 &&
            json_response['response']['reason'] == 'Request successfully processed'
    end
end