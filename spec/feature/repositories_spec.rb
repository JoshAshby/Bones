# frozen_string_literal: true

feature "creating a repo" do
  before do
    create_user
    login_user
    visit "/dashboard/repository/create"
  end

  scenario "valid input" do
    fill_in "repository[name]", with: "testing"
    click_button "Create Repository"

    expect(page).to have_current_path("/dashboard")
    expect(page).to have_text("Your repository has been created")
    expect(page).to have_text("Password: ")
  end
end
