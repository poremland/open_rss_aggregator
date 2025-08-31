require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Hello'
    end

    def secure?
      super
    end
  end

  describe '#index' do
    it 'redirects to the login page' do
      get :index
      expect(response).to redirect_to('/login/login')
    end
  end

  describe '#secure?' do
    it 'returns false by default' do
      expect(controller.secure?).to be_falsey
    end
  end
end
