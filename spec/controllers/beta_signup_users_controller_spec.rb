# require 'spec_helper'

# # This spec was generated by rspec-rails when you ran the scaffold generator.
# # It demonstrates how one might use RSpec to specify the controller code that
# # was generated by Rails when you ran the scaffold generator.
# #
# # It assumes that the implementation code is generated by the rails scaffold
# # generator.  If you are using any extension libraries to generate different
# # controller code, this generated spec may or may not pass.
# #
# # It only uses APIs available in rails and/or rspec-rails.  There are a number
# # of tools you can use to make these specs even more expressive, but we're
# # sticking to rails and rspec-rails APIs to keep things simple and stable.
# #
# # Compared to earlier versions of this generator, there is very limited use of
# # stubs and message expectations in this spec.  Stubs are only used when there
# # is no simpler way to get a handle on the object needed for the example.
# # Message expectations are only used when there is no simpler way to specify
# # that an instance is receiving a specific message.

# describe BetaSignupUsersController do

#   # This should return the minimal set of attributes required to create a valid
#   # BetaSignupUser. As you add validations to BetaSignupUser, be sure to
#   # adjust the attributes here as well.
#   let(:valid_attributes) { { "email" => "MyString" } }

#   # This should return the minimal set of values that should be in the session
#   # in order to pass any filters (e.g. authentication) defined in
#   # BetaSignupUsersController. Be sure to keep this updated too.
#   let(:valid_session) { {} }

#   describe "GET index" do
#     it "assigns all beta_signup_users as @beta_signup_users" do
#       beta_signup_user = BetaSignupUser.create! valid_attributes
#       get :index, {}, valid_session
#       assigns(:beta_signup_users).should eq([beta_signup_user])
#     end
#   end

#   describe "GET show" do
#     it "assigns the requested beta_signup_user as @beta_signup_user" do
#       beta_signup_user = BetaSignupUser.create! valid_attributes
#       get :show, {:id => beta_signup_user.to_param}, valid_session
#       assigns(:beta_signup_user).should eq(beta_signup_user)
#     end
#   end

#   describe "GET new" do
#     it "assigns a new beta_signup_user as @beta_signup_user" do
#       get :new, {}, valid_session
#       assigns(:beta_signup_user).should be_a_new(BetaSignupUser)
#     end
#   end

#   describe "GET edit" do
#     it "assigns the requested beta_signup_user as @beta_signup_user" do
#       beta_signup_user = BetaSignupUser.create! valid_attributes
#       get :edit, {:id => beta_signup_user.to_param}, valid_session
#       assigns(:beta_signup_user).should eq(beta_signup_user)
#     end
#   end

#   describe "POST create" do
#     describe "with valid params" do
#       it "creates a new BetaSignupUser" do
#         expect {
#           post :create, {:beta_signup_user => valid_attributes}, valid_session
#         }.to change(BetaSignupUser, :count).by(1)
#       end

#       it "assigns a newly created beta_signup_user as @beta_signup_user" do
#         post :create, {:beta_signup_user => valid_attributes}, valid_session
#         assigns(:beta_signup_user).should be_a(BetaSignupUser)
#         assigns(:beta_signup_user).should be_persisted
#       end

#       it "redirects to the created beta_signup_user" do
#         post :create, {:beta_signup_user => valid_attributes}, valid_session
#         response.should redirect_to(BetaSignupUser.last)
#       end
#     end

#     describe "with invalid params" do
#       it "assigns a newly created but unsaved beta_signup_user as @beta_signup_user" do
#         # Trigger the behavior that occurs when invalid params are submitted
#         BetaSignupUser.any_instance.stub(:save).and_return(false)
#         post :create, {:beta_signup_user => { "email" => "invalid value" }}, valid_session
#         assigns(:beta_signup_user).should be_a_new(BetaSignupUser)
#       end

#       it "re-renders the 'new' template" do
#         # Trigger the behavior that occurs when invalid params are submitted
#         BetaSignupUser.any_instance.stub(:save).and_return(false)
#         post :create, {:beta_signup_user => { "email" => "invalid value" }}, valid_session
#         response.should render_template("new")
#       end
#     end
#   end

#   describe "PUT update" do
#     describe "with valid params" do
#       it "updates the requested beta_signup_user" do
#         beta_signup_user = BetaSignupUser.create! valid_attributes
#         # Assuming there are no other beta_signup_users in the database, this
#         # specifies that the BetaSignupUser created on the previous line
#         # receives the :update_attributes message with whatever params are
#         # submitted in the request.
#         BetaSignupUser.any_instance.should_receive(:update).with({ "email" => "MyString" })
#         put :update, {:id => beta_signup_user.to_param, :beta_signup_user => { "email" => "MyString" }}, valid_session
#       end

#       it "assigns the requested beta_signup_user as @beta_signup_user" do
#         beta_signup_user = BetaSignupUser.create! valid_attributes
#         put :update, {:id => beta_signup_user.to_param, :beta_signup_user => valid_attributes}, valid_session
#         assigns(:beta_signup_user).should eq(beta_signup_user)
#       end

#       it "redirects to the beta_signup_user" do
#         beta_signup_user = BetaSignupUser.create! valid_attributes
#         put :update, {:id => beta_signup_user.to_param, :beta_signup_user => valid_attributes}, valid_session
#         response.should redirect_to(beta_signup_user)
#       end
#     end

#     describe "with invalid params" do
#       it "assigns the beta_signup_user as @beta_signup_user" do
#         beta_signup_user = BetaSignupUser.create! valid_attributes
#         # Trigger the behavior that occurs when invalid params are submitted
#         BetaSignupUser.any_instance.stub(:save).and_return(false)
#         put :update, {:id => beta_signup_user.to_param, :beta_signup_user => { "email" => "invalid value" }}, valid_session
#         assigns(:beta_signup_user).should eq(beta_signup_user)
#       end

#       it "re-renders the 'edit' template" do
#         beta_signup_user = BetaSignupUser.create! valid_attributes
#         # Trigger the behavior that occurs when invalid params are submitted
#         BetaSignupUser.any_instance.stub(:save).and_return(false)
#         put :update, {:id => beta_signup_user.to_param, :beta_signup_user => { "email" => "invalid value" }}, valid_session
#         response.should render_template("edit")
#       end
#     end
#   end

#   describe "DELETE destroy" do
#     it "destroys the requested beta_signup_user" do
#       beta_signup_user = BetaSignupUser.create! valid_attributes
#       expect {
#         delete :destroy, {:id => beta_signup_user.to_param}, valid_session
#       }.to change(BetaSignupUser, :count).by(-1)
#     end

#     it "redirects to the beta_signup_users list" do
#       beta_signup_user = BetaSignupUser.create! valid_attributes
#       delete :destroy, {:id => beta_signup_user.to_param}, valid_session
#       response.should redirect_to(beta_signup_users_url)
#     end
#   end

# end
