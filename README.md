# Whoru

A Rails plugin handling login stuff in Controller

## Installation

add `gem 'whoru'` in the `Gemfile` and then `$ bundle install`

## Login
### Usage:
in `users_controller.rb`
```ruby
class UsersController < ApplicationController
  include Whoru
  login FacebookUser, :with => :facebook_login
end
```

in `config/routes.rb`
```ruby
post '/fb_login' => 'users#facebook_login'
```

After the setup above, the `/fb_login` api would take 

```json
{
  "account": "the-account",
  "validator": "the-validator"
}
```

- `200`: When success, returns `user.as_json` 
- `409`: When login failed, returns `409`
- `400`: Returns `400` if miss parameters

### App Login:
Append `access_token` onto response.

### Web Login:
`whoru` does web login if `params[:cookie]` exists.
When web login, `whoru` appends `access_token` on `cookies['WHORU']`, instead of appending it on response.


### How it works:
Take the setup above as an example:

`whoru` create a method `facebook_login` on the fly.
In the created method, `whoru` takes `params[:account]` and `params[:validator]` 
and pass them into `FacebookUser::login(account, validator)`, which should return a user.

`whoru` then invokes `user#generate_access_token`(`user#generate_web_access_token` for web login) and appends it on response / cookies.
It would raise `Whoru::MethodNotImplementedException` if any one of `FacebookUser::login`, `FacebookUser#generate_access_token`, `FacebookUser#generate_web_access_token` is not implemented.


### Model Requirement

- `UserClass::login(account, validator)`: 
should return a user if account and valiator are matched, return `nil` if not.

- `UserClass#generate_access_token`: 
should return an access token used by app login

- `UserClass#generate_web_access_token`:
should return an access for web login

----

## Authenticate
### Usage:
config `ApplicationController` or any controller class to be inherited:

```ruby
class ApplicationController
  include Whoru::Authenticate
  authenticate :user_class => User,               # required
               :with => :authenticate,            # optional, default to `whoru_authenticate`
               :user_id => :user_id,              # optional, default to `:user_id`
               :header_token => 'x-access-token', # optional, default to `x-access-token`
end
```

The setting above creates an instance method `authenticate` on ApplicationController and assigns `before_filter` to that method.

The created `authenticate` method will:

- passes if no `user_id` in params
- return `404` if User of `params[:user_id]` not found
- return `401` if no `x-access-token` in request header
- return `401` if `x-access-token` does not match with the user, this is done by `User#has_access_token(token)`

## Model Requirements:
- `User#has_access_token?(token)`: takes a string as argument, returns if user has the given access token


----

## Testing
Testing is good for your health. 

In some testing senarios you want to assume all the user authentication stuff just work (it's the responsibility of `whoru` anyway.)
`whoru` provides a helper method using `RSpec` to do that:
 
in `rails_helper.rb`:

```ruby
require 'whoru/stub'
```

in `some_controller_spec.rb`

```ruby
describe 'POST :create' do
  include Whoru::Stub

  before :each do
    stub_authenticate
  end
end
```

this will make the authentication filter always pass in the test case.


## Licence: 
MIT
