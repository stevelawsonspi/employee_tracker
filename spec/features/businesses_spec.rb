require 'rails_helper'

RSpec.feature 'As an admin user, looking at all businesses', :js do
  include Devise::Test::IntegrationHelpers

  before(:each) do
    @user       = create(:user)
    @admin_user = create(:user, admin: true)
    @business   = create(:business, user_id: @user.id, name: 'Business111', abn: '123')
    @business   = create(:business, user_id: @user.id, name: 'Business222', abn: '234')
    @business   = create(:business, user_id: @user.id, name: 'Business333', abn: '345')
    @business   = create(:business, user_id: @user.id, name: 'Business444', abn: '456')
  end

  scenario 'Redirects to User Businesses if not admin user' do
    sign_in @user
    visit   businesses_path

    expect(page).to have_current_path(user_businesses_path)
  end

  scenario 'I will see all businesses' do
    sign_in @admin_user
    visit   businesses_path

    expect(page).to have_content 'All Businesses'
    expect(page).to have_content 'Business111'
    expect(page).to have_content 'Business222'
    expect(page).to have_content 'Business333'
    expect(page).to have_content 'Business444'
    expect(page).to have_content 'New Business'
  end
  
  scenario 'Search shows only matching' do
    sign_in @admin_user
    visit   businesses_path
    fill_in 'search', with: '222'
    click_button 'search_button'

    expect(page).to     have_content 'All Businesses'
    expect(page).not_to have_content 'Business111'
    expect(page).to     have_content 'Business222'
  end
  
  scenario 'Clear Search clears the search' do
    sign_in @admin_user
    visit   businesses_path
    fill_in 'search', with: '222'
    click_button 'search_button'

    expect(page).to     have_content 'All Businesses'
    expect(page).not_to have_content 'Business111'
    expect(page).to     have_content 'Business222'
    
    click_link 'cancel_search_button'

    expect(page).to have_content 'All Businesses'
    expect(page).to have_content 'Business111'
    expect(page).to have_content 'Business222'
  end
end
