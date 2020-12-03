# frozen_string_literal: true

describe "repositories", type: :feature do
  describe "Creating a repo" do
    before do
      create_user
      login_user

      visit "/dashboard/repository/create"
    end

    it "with valid input" do
      fill_in "repository[name]", with: "testing"
      click_button "Create"

      expect(page).to have_current_path("/dashboard")

      expect(page).to have_text("Your repository has been created")
      expect(page).to have_text("Password: ")
    end

    it "with invalid input" do
      fill_in "repository[name]", with: "testing/one"
      click_button "Create"

      expect(page).to have_current_path("/dashboard/repository/create")

      expect(page).to have_text("Can only contain letters, numbers, underscores and dashes")
    end
  end

  describe "Deleting a repo" do
    let(:username) { "testing" }

    before do
      account_id = create_user
      login_user

      Bones::UserFossil.new(username).create_repository "testing"
      id = DB[:repositories].insert account_id: account_id, name: "testing"

      visit "/dashboard/repository/#{ id }/delete"
    end

    it "deletes with the correct name" do
      fill_in "repository[name]", with: "testing"
      click_button "Got it, please delete this repository"

      expect(page).to have_current_path("/dashboard")
      expect(page).to have_text("Repository testing was deleted!")

      expect(Bones::UserFossil.new(username).repository("testing").path).not_to exist
    end

    it "errors with an incorrect name" do
      fill_in "repository[name]", with: "tes"
      click_button "Got it, please delete this repository"

      expect(page).to have_current_path("/dashboard")
      expect(page).to have_text("Repository name did not match, testing was NOT deleted!")

      expect(Bones::UserFossil.new(username).repository("testing").path).to exist
    end
  end
end
