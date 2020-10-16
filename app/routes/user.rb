# frozen_string_literal: true

CreateForm = Struct.new :name, :password, :project_name, keyword_init: true
CloneForm = Struct.new :name, :password, :clone_url, keyword_init: true

class Routes::User < Routes::Base
  route do |r|
    @account_id = rodauth.session_value

    r.on "repository" do
      r.on "create" do
        r.get { @form = CreateForm.new; view "repository/create" }
        r.post do
          form = CreateForm.new r.params.slice(*CreateForm.members.map(&:to_s))

          username = DB[:accounts].where(id: @account_id).get(:username)
          repo = Bones::UserFossil.new(username).repository form.name

          repo.create_repository! username: username
          password = repo.change_password username: username, password: form.password

          repo.repository_db do |db|
            db[:config].where(name: 'localauth').update(value: 1)
            db[:config].where(name: 'project-name').update(value: form.project_name) if form.project_name
          end

          DB[:repositories].insert account_id: @account_id, name: form.name

          flash[:repository_password] = password
          flash[:info] = "Successfully created repository #{form.name}!"
          r.redirect "/user"
        end
      end

      r.on "clone" do
        r.get {view "repository/clone" }
        r.post do

        end
      end
    end

    r.root do
      @repositories = DB[:repositories].where(account_id: @account_id)
      view "user/index"
    end
  end
end
