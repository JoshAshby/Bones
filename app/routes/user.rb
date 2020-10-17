# frozen_string_literal: true

class Routes::User < Routes::Base
  route do |r|
    r.on "repository" do
      shared[:breadcrumbs] << "Repository"

      r.on "id", Integer do
        shared[:breadcrumbs] << r.params[:id]

        r.on "edit" do
          shared[:breadcrumbs] << "Edit"
          r.get { view "repository/edit" }
          r.post {}
        end

        r.on "delete" do
          shared[:breadcrumbs] << "Delete?"
          r.get { view "repository/delete" }
          r.post {}
        end
      end

      r.on "create" do
        shared[:breadcrumbs] << "Create Repository"

        r.get do
          @form = Forms::CreateRepository.new
          view "repository/create"
        end

        r.post do
          form = Forms::CreateRepository.from_params r.params

          password = Bones::UserFossil.new(shared[:account][:username]).create_repository(
            form.name,
            admin_password: form.password,
            project_name: form.project_name
          )

          repo_id = DB[:repositories].insert account_id: rodauth.session_value, name: form.name

          # Stash this so we can display it on the next page
          flash[:repository_password] = password
          flash[:repository_id] = repo_id

          flash[:info] = "Successfully created repository #{ form.name }!"

          r.redirect "/dashboard"
        end
      end

      r.on "clone" do
        shared[:breadcrumbs] << "Clone Repository"

        r.get do
          @form = Forms::CloneRepository.new
          view "repository/clone"
        end

        r.post do
          form = Forms::CloneRepository.from_params r.params

          password = Bones::UserFossil.new(shared[:account][:username]).clone_repository(
            form.name,
            admin_password: form.password,
            url: form.clone_url
          )

          repo_id = DB[:repositories].insert account_id: rodauth.session_value, name: form.name, cloned_from: form.clone_url

          # Stash this so we can display it on the next page
          flash[:repository_password] = password
          flash[:repository_id] = repo_id

          flash[:info] = "Successfully cloned repository #{ form.name }!"

          r.redirect "/user"
        end
      end
    end

    r.root do
      @repositories = DB[:repositories].where(account_id: rodauth.session_value)
      view "user/index"
    end
  end
end
