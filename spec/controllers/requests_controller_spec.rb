require 'spec_helper.rb'

describe RequestsController do

  include_context 'auth_helpers'

  describe 'access control rules' do

    # let will not be initialized for shared example groups
    a_request = FactoryGirl.build_stubbed(:request, requester_email: 'iceking@coolmail.com')

    setup = Proc.new do
      # appease the set_request callback
      before { Request.stub(:find).with(a_request.id.to_s) { a_request } }
    end

    # get new
    it_behaves_like 'action requires groups or attribute',
                    [:admin, :lec], :umbcDepartment, 'Library', :get, :new

    # post create
    it_behaves_like 'action requires groups or attribute',
                    [:admin, :lec], :umbcDepartment, 'Library', :post, :create

    # get my_requests
    it_behaves_like 'action requires groups or attribute',
                    [:admin, :lec], :umbcDepartment, 'Library', :get, :my_requests

    # get old_requests
    it_behaves_like 'action requires groups or attribute',
                    [:admin, :lec], :umbcDepartment, 'Library', :get, :old_requests

    # get edit
    it_behaves_like 'action requires groups or attribute',
                    [:admin, :lec], :mail, a_request.requester_email,
                    :get, :edit, id: a_request, request: a_request, &setup

    # patch update
    it_behaves_like 'action requires groups or attribute',
                    [:admin, :lec], :mail, a_request.requester_email,
                    :patch, :update, id: a_request, request: a_request, &setup

    # delete destroy
    it_behaves_like 'action requires groups or attribute',
                    [:admin, :lec], :mail, a_request.requester_email,
                    :delete, :destroy, id: a_request, request: a_request, &setup

    # get review
    it_behaves_like 'action requires groups', [:admin, :lec], :get, :review
    # patch approve
    it_behaves_like 'action requires groups', [:admin, :lec], :patch, :approve, id: a_request, &setup
    # patch deny
    it_behaves_like 'action requires groups', [:admin, :lec], :patch, :deny, id: a_request, &setup
  end

  describe 'action unit tests' do
    let(:web_request) { FactoryGirl.build_stubbed(:request) }

    before do
      log_in_as(umbcusername: 'admin_user', group: 'admin')
      Request.stub(:find).with(web_request.id.to_s) { web_request }
    end

    describe 'GET #show' do
      it 'assigns the correct request to @request' do
        get :show, id: web_request
        expect(assigns(:request)).to eq(web_request)
      end
      it 'renders the :show view' do
        get :show, id: web_request
        expect(response).to render_template :show
      end
    end

    describe 'GET #new' do
      it 'assigns a new Request to @request' do
        get :new
        expect(assigns(:request)).to be_a_new(Request)
      end
      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'GET #edit' do
      it 'assigns the correct request to @request' do
        get :edit, id: web_request
        expect(assigns(:request)).to eq(web_request)
      end
      it 'renders the :edit template' do
        get :edit, id: web_request
        expect(response).to render_template :edit
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'saves the new request to the db' do
          expect {
            post :create, request: FactoryGirl.attributes_for(:request)
          }.to change(Request, :count).by(1)
        end
        it 'redirects to the #index' do
          post :create, request: FactoryGirl.attributes_for(:request)
          expect(response).to redirect_to Request.last
        end
        it 'sends a confirmation email' do
          expect {
              post :create, request: FactoryGirl.attributes_for(:request)
          }.to change{emails.count}.by(1)
        end
      end

      context 'with invalid attributes' do
        it 'does not save the request to the db'  do
          expect {
            post :create, request: FactoryGirl.attributes_for(:invalid_webinar_request)
          }.to_not change(Request, :count)
        end
        it 're-renders the :new template' do
          post :create, request: FactoryGirl.attributes_for(:invalid_webinar_request)
          expect(response).to render_template :new
        end
        it 'does not send an email' do
          expect {
            post :create, request: FactoryGirl.attributes_for(:invalid_webinar_request)
          }.not_to change{emails.count}
        end
      end
    end

    describe 'PATCH #update' do
      let(:attrs) { {'name' => '1'} }
      before { allow(web_request).to receive(:update) }

      it 'loads the correct request to @request' do
        patch :update, id: web_request, request: attrs
        expect(assigns(:request)).to eq(web_request)
      end
      it 'attempts to save the attrs to the db' do
        patch :update, id: web_request, request: attrs
        expect(web_request).to have_received(:update).with(attrs)
      end

      context 'with valid attributes' do
        before { allow(web_request).to receive(:update).and_return(true) }

        it 'redirects to the updated request/show view' do
          patch :update, id: web_request, request: attrs
          expect(response).to redirect_to web_request
        end
        it 'sends an update email' do
          expect {
            patch :update, id: web_request, request: attrs
          }.to change{emails.count}.by(1)
        end
      end
      context 'with invalid attributes' do
        before { allow(web_request).to receive(:update).and_return(false) }

        it 're-renders to the :edit template' do
          patch :update, id: web_request, request: attrs
          expect(response).to render_template :edit
        end
        it 'does not send an email' do
          expect {
            patch :update, id: web_request, request: attrs
          }.not_to change{emails.count}
        end
      end
    end

    describe 'DELETE #destroy' do
      before { allow(web_request).to receive(:destroy) }

      it 'deletes the request from the db' do
        delete :destroy, id: web_request
        expect(web_request).to have_received(:destroy)
      end
      it 'redirects to #index' do
        delete :destroy, id: web_request
        expect(response).to redirect_to requests_url
      end
      it 'sends an update email' do
        expect {
          delete :destroy, id: web_request
        }.to change{emails.count}.by(1)
      end
    end

    describe 'get #my_requests' do
      let(:my_requests) { Array.new(2) { FactoryGirl.build_stubbed(:request, requester_email: 'alibrarian@umbc.edu') } }

      before do
        logout #ensures no group permissions are set
        set_env_attribute(:umbcDepartment, 'Library')
        set_env_attribute(:mail, 'alibrarian@umbc.edu')

        Request.stub_chain(:where, :order) { my_requests }
      end

      it "retrieves a list of the user's requests" do
        get :my_requests
        expect(assigns(:requests)).to eq my_requests
      end
      it 'renders the my_requests view' do
        get :my_requests
        expect(response).to render_template :my_requests
      end
    end

    describe 'get #old_requests' do
      let(:old_requests) { Array.new(2) { FactoryGirl.build_stubbed(:request, requester_email: 'alibrarian@umbc.edu') } }

      before do
        logout #ensures no group permissions are set
        set_env_attribute(:umbcDepartment, 'Library')
        set_env_attribute(:mail, 'alibrarian@umbc.edu')

        Request.stub_chain(:where, :order) { old_requests }
      end

      it "retrieves a list of the user's requests" do
        get :old_requests
        expect(assigns(:requests)).to eq old_requests
      end
      it 'renders the my_requests view' do
        get :old_requests
        expect(response).to render_template :old_requests
      end
    end

    describe 'get #review' do
      it 'assigns webinar by review status' do
        shatner  = FactoryGirl.build_stubbed(:request, description: "William Shatner's new Christmas album")
        zeppelin = FactoryGirl.build_stubbed(:request, description: "Led Zeppelin's reunion tour",
                                             approved: true, reviewed: true)
        icp      = FactoryGirl.build_stubbed(:request, description: "Insane Clown Posse raps about science",
                                             approved: false, reviewed: true)

        Request.stub_chain(:all, :order) { [shatner, zeppelin, icp] }

        get :review
        expect(assigns(:requests_by_status)).to eq({'unreviewed' => [shatner], 'approved' => [zeppelin], 'denied' => [icp]})
      end

      it 'assigns a list of statuses' do
        get :review
        expect(assigns(:statuses)).to include('unreviewed', 'approved', 'denied')
      end
    end

    describe 'patch #approve' do
      before { allow(web_request).to receive(:approve) }

      it 'calls the approve method on the request' do
        patch :approve, id: web_request.id
        expect(web_request).to have_received(:approve)
      end

      it 'redirects to the review action' do
        patch :approve, id: web_request.id
        expect(response).to redirect_to admin_review_path
      end

      it 'sends an update email' do
        expect {
          patch :approve, id: web_request.id
        }.to change{emails.count}.by(1)
      end
    end

    describe 'patch #deny' do
      before { allow(web_request).to receive(:deny) }

      it 'calls the deny method on the request' do
        patch :deny, id: web_request.id
        expect(web_request).to have_received(:deny)
      end

      it 'redirects to the review action' do
        patch :deny, id: web_request.id
        expect(response).to redirect_to admin_review_path
      end

      it 'sends an update email' do
        expect {
          patch :deny, id: web_request.id
        }.to change{emails.count}.by(1)
      end
    end
  end

  # email alias
  def emails
    ActionMailer::Base.deliveries
  end
end