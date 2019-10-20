![General Assembly](https://github.com/fedelopez/rails-basic-auth/blob/master/docs/generalassembly.png)

# Rails Basic Authentication

Create Rails app with no test files, not git init and for Postgres:

```bash
rails new rails-basic-auth -T --skip-git --database=postgresql
```

Create the DB:

```bash
cd rails-basic-auth
rails db:create
```

Create our User model and the migration for creating the users table in the DB:

```bash
rails generate model User name:string password_digest:string age:integer email:string
```

Run the migration generated to create the users table in the database.

```bash
rails db:migrate
```

## Seeding the DB

In order to allow valid users to login, we are going to seed the DB with a few users we can use to test the login flow works.

Open the `db/seeds.rb` and enter the following users:

```ruby
User.create(name: 'luke', password_digest: BCrypt::Password.create('Jedi'), age: 23, email: 'luke@ga.com')
User.create(name: 'han', password_digest: BCrypt::Password.create('Falcon'), age: 25, email: 'han@ga.com')
User.create(name: 'leia', password_digest: BCrypt::Password.create('Alderaan'), age: 23, email: 'leia@ga.com')
```

Now seed the DB to apply insert the users:

```bash
rails db:seed
```

## Password encryption

Now, we need to use our Gemfile to get something that does the password encryption (hashing). 
We normally use [bcrypt](https://github.com/codahale/bcrypt-ruby) for this.

Open the file `Gemfile` and uncomment the following line:

```ruby
gem 'bcrypt', '~> 3.1.7'
```

Download the dependency:

```bash
bundle
```

Open the file `app/models/user.rb` add the following line:

`has_secure_password`

```ruby
class User < ApplicationRecord
  has_secure_password
end
```

Including this method in our user model adds methods to set and authenticate encrypted passwords. 
In order for the `has_secure_password` method to work, your database table _must_ have a `password_digest` column.

Read more about `has_secure_password`: https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html

## Create a session controller

Our session controller has no associated model and only requires three actions:

- new: shows the login form
- create: signs in the use
- destroy: logs out the user

```bash
rails generate controller Session new create destroy
```

Note: This will create two views that we don't need. Delete those.

```bash
rm app/views/session/create.html.erb
rm app/views/session/destroy.html.erb
```

Note: This will also have create several routes that we don't want. Delete the following routes from your `config/routes.rb` file:

```ruby
get 'session/new'
get 'session/create'
get 'session/destroy'
```

Create a `Pages` controller with a `home` action that will be the main entry point of the app:

```bash
rails generate controller Pages home
```

Note: This will also generate an unwanted. Delete the following route from your `config/routes.rb` file:

```ruby
get 'pages/home'
```

Add the following routes to your config/routes.rb file:

```ruby
root :to => 'pages#home' # the root will point to the home action of the Pages controller            
get '/login' => 'session#new'         # This will be our sign-in page.
post '/login' => 'session#create'     # This will be the path to which the sign-in form is posted
delete '/login' => 'session#destroy'  # This will be the path users use to log-out.
```

#### Add log-in / sign-out links to our layout

Open the file `app/views/pages/home.html.erb`.

Add the following links to allow users login and logout.

```html
<ul>
  <li><%= link_to("Login", controller: "session", action: "new") %></li>
  <li><%= link_to("Logout", login_path, :method => :delete) %></li>
</ul>
```
TODO: homogenise the link_to

- Login points to the action `new` on the `SessionController` (`app/controllers/session_controller.rb`)
- Logout points to the action `delete` on the `SessionController`  

## Creating the login form

In order to login, we are going to show a login form on the `/login` page.

Open the associated view to the login page `app/views/session/new.html.erb` and add the following form:

```html
<h1>Login</h1>
<%= form_with(url: "/login", method: "post") do %>
  <div>
    <label>
      Email
      <input type="email" name="email"/>
    </label>
  </div>
  <div>
    <label>
      Password
      <input type="password" name="password"/>
    </label>
    <div>
      <input type="submit" value="Login"/>
    </div>
  </div>
<% end %>
```

When the user will click the `Login` button the browser is going to call the action `create` on the controller `SessionController`.
This `create` action will be called because the route `/login` with the method `post` is associated to it on the `config/routes.rb`. 

## Handling the login form submission 

Now that we have a login form, we need to implement the `create` action to 

- login the user if the credentials are ok and redirect to the home screen
- show the user an error message if the credentials are wrong and stay on the login form 

Open the file `app/controllers/session_controller.rb` and update the `create` action:

This is the action to which the login form post request is posted. 
It will add the user id to the session hash, which will be used for authentication and authorization throughout the session.

```ruby
def create
    user = User.find_by :email => params[:email] # find the user in the DB by the email provided (note :email maps to the email in the form input)
    if user.present? && user.authenticate(params[:password]) # if user exists check if credentials match
      # user exists, store their id in the session hash and redirect them to the root path
      session[:user_id] = user.id
      redirect_to root_path
    else
      # If the user cannot be authenticated, redirect them to the /login screen again.
      redirect_to '/login'
    end
  end
```

## Showing login error messages

We would like to show an error message to the user when the credentials are invalid.

Open the `create` action from the `SessionController`

Add the following line before redirecting the user to the login screen when authentication fails

```ruby
flash[:error] = 'Invalid credentials'
```

The `flash` hash is a special part of the session that is cleared after each HTTP request - this means that values stored
there will only be available in the next request, which is useful for passing error messages between actions. 

The method should now look like this:

```ruby
def create
    user = User.find_by :email => params[:email] 
    if user.present? && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash[:error] = 'Invalid credentials' # add a flash message to later be used by the view
      redirect_to '/login'
    end
  end
```

Now open the `SessionController` class and modify the `new` action to create a variable with the value
of the flash error message:

```ruby
def new
  @error_message = flash[:error] # if there is an error, we can now display it in the form
end
```

And the form should now show the error whenever the credentials are invalid:

```html
<h1>Login</h1>
<%= form_with(url: "/login", method: "post") do %>
  <div>
    <label>
      Email
      <input type="email" name="email"/>
    </label>
  </div>
  <div>
    <label>
      Password
      <input type="password" name="password"/>
    </label>
    <div>
      <input type="submit" value="Login"/>
    </div>
  </div>
<% end %>
<div>
  <%= @error_message %>
</div>
```

## Welcoming a logged in user

We would like to show a welcome message when a user successfully logs in.

If a user is logged in, the session hash will have a key named `:user_id` with the row id of the logged in user.

Let's create a variable with the user information so we can welcome the user by their name in the home view once they 
have been logged in.

Open the `app/controllers/pages_controller.rb` and create a variable in the action to find the logged in user from the DB:

```ruby
class PagesController < ApplicationController
  def home
    @logged_in_user = User.find_by :id => session[:user_id]
  end
end
```

Let's enrich the `home.html.erb` view to display a welcome message if the user is successfully logged in:

```html
<h1>Home</h1>
<% if @logged_in_user.nil? %>
  <h2>Sign-in</h2>
  <li><%= link_to("Login", controller: "session", action: "new") %></li>
<% else %>
  <h2>Welcome back, <%= @logged_in_user.name %>!</h2>
  <li><%= link_to("Logout", login_path, :method => :delete) %></li>
<% end %>
```






