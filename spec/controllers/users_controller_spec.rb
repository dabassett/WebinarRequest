require 'spec_helper'

describe UsersController do

  include_context 'auth_helpers'

  describe 'access control rules' do
    before { allow(User).to receive(:find) }

    # get #index
    it_behaves_like 'action requires groups', :admin, :get, :index

    # get #show
    it_behaves_like 'action requires groups', :admin, :get, :show , id: 1

    # get #new
    it_behaves_like 'action requires groups', :admin, :get, :new

    # post #create
    it_behaves_like 'action requires groups', :admin, :post, :create

    # get #edit
    it_behaves_like 'action requires groups', :admin, :get, :edit, id: 1

    # patch #update
    it_behaves_like 'action requires groups', :admin, :patch, :update, id: 1

    # delete #destroy
    it_behaves_like 'action requires groups', :admin, :delete, :destroy, id: 1
  end
end