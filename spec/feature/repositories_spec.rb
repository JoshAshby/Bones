# frozen_string_literal: true

describe "Creating a repo", type: :feature do
  before do
    create_user
    login_user

    visit "/dashboard/repository/create"
  end

  it "with valid input" do
    fill_in "repository[name]", with: "testing"
    click_button "Create Repository"

    expect(page).to have_current_path("/dashboard")

    expect(page).to have_text("Your repository has been created")
    expect(page).to have_text("Password: ")
  end
end
