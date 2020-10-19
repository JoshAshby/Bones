# frozen_string_literal: true

class Routes::User < Routes::Base
  route do |r|
    shared[:breadcrumbs] << "Dashboard"
    set_layout_options template: :layout_logged_in

    r.on "repository" do
      shared[:breadcrumbs] << "Repository"

      r.on Integer do |id|
        shared[:breadcrumbs] << id

        r.on "edit" do
          shared[:breadcrumbs] << "Edit"

          r.get do
            @form = Forms::EditRepository.new id: id
            view "dashboard/repository/edit"
          end

          r.post do
            @form = Forms::EditRepository.from_params(r.params) do |params|
              params.merge id: id
            end

            next view "dashboard/repository/edit" unless @form.save

            flash[:info] = "Repository #{ @form.repository[:name] } updated!"

            unless @form.password.blank?
              flash[:repository_password] = @form.password
              flash[:repository_id] = @form.id
            end

            r.redirect "/dashboard"
          end
        end

        r.on "delete" do
          shared[:breadcrumbs] << "Delete"
          @repository = DB[:repositories].first id: id

          r.get do
            view "dashboard/repository/delete"
          end

          r.post do
            if r.params["repository"]["name"] == @repository[:name]
              repo = Bones::UserFossil.new(session["username"]).repository @repository[:name]
              repo.delete_repository!

              DB[:repositories].where(id: id).delete

              flash[:info] = "Repository #{ @repository[:name] } was deleted!"

              r.redirect "/dashboard"
            end

            flash[:error] = "Repository name did not match, #{ @repository[:name] } was NOT deleted!"

            r.redirect "/dashboard"
          end
        end
      end

      r.on "create" do
        shared[:breadcrumbs] << "Create Repository"

        r.get do
          @form = Forms::CreateRepository.new name: nil
          view "dashboard/repository/create"
        end

        r.post do
          @form = Forms::CreateRepository.from_params(r.params)

          unless @form.save account_id: rodauth.session_value, username: shared[:account][:username]
            next view "dashboard/repository/create"
          end

          flash[:info] = "Repository #{ @form.repository[:name] } created!"

          unless @form.password.blank?
            flash[:repository_password] = @form.password
            flash[:repository_id] = @form.repository[:id]
          end

          r.redirect "/dashboard"
        end
      end

      r.on "clone" do
        shared[:breadcrumbs] << "Clone Repository"

        r.get do
          @form = Forms::CloneRepository.new name: nil, clone_url: nil
          view "dashboard/repository/clone"
        end

        r.post do
          @form = Forms::CloneRepository.from_params(r.params)

          unless @form.save account_id: rodauth.session_value, username: shared[:account][:username]
            next view "dashboard/repository/clone"
          end

          flash[:info] = "Repository #{ @form.repository[:name] } cloned from #{ @form.clone_url }!"

          unless @form.password.blank?
            flash[:repository_password] = @form.password
            flash[:repository_id] = @form.repository[:id]
          end

          r.redirect "/dashboard"
        end
      end
    end

    r.root do
      @repositories = DB[:repositories].where(account_id: rodauth.session_value)
      view "dashboard/index"
    end
  end
end
