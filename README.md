# Authz
[![Build Status](https://travis-ci.com/serodriguez68/authz.svg?token=qXv4Wq7cPeFBwcByqvAc&branch=develop)](https://travis-ci.com/serodriguez68/authz)

**Authz** is an **opinionated** *almost*-**turnkey** solution for managing **authorization** in your Rails application.

Authz provides you with:
- An **authorization admin** interface that allows non-developers to configure and manage how authorization works for your app. 
The admin makes it very easy to answer questions like *"who can create top-secret reports"?* or *"what can John Doe do?"* 
- An **opinionated** approach on how to structure your permissions that promotes clarity and maintainability.
- An easy-to-use API that allows developers to integrate *Authz* into their apps with **very little code** while providing
them with the tools they need. 
  - *"Can I make my views dynamic depending on the user's authorization?"* Yup!
  - *"Can I retrieve only the records the user has access to?"* Sure thing!
  - *"The role structure inside my organization changes frequently and I spend a lot of time updating the 'who-can-do-what' 
  code to keep up with the changes.'"* No worries. Use the admin to make the 
  tweaks you need, no code changes.

Get a feel for **Authz** with this [video overview (coming soon)](TO-DO).


## Is Authz A Good Match For My Needs?
Authz is not a good match for everyone since applications can have widely different authorization requirements. 
Use the following questions to help you assess if Authz is a good match for you.
 
1. Are you expecting to use Authz to authorize other applications other than the application you installed it in? 
(e.g. Using it as an authorization service for another app.)
    - **Yes**: Sorry, Authz was built to provide authorization for its host app only.
    - **No**: Good match! 

2. Do you need to grant authorization considering factors other than **the action** that is being performed 
and **the instance/resource** it is being performed on?
    - For example:
        - Users must be denied access after 10 pm.
        - Users must be granted access based on their IP address.
        - Customers must be denied access when the transaction amount is greater than $5000.
    - **Yes**. If these types of rules are not very common in your app, you may still benefit from Authz provided that you
 take care of these cases yourself.  If they are common, you are better off checking out other projects like 
 [Pundit](https://github.com/varvet/pundit#policies) or [CanCanCan](https://github.com/CanCanCommunity/cancancan).
    - **No**: Good match!

3. Here are some examples of rules that can be configured in Authz. Do they look compatible with your needs?
    - Examples:
        - The *general director* **role** must be able to *index/show/new/create/...* the **reports** from **all cities**
        and **all departments**.
        - The *regional director* **role** must be able to *index/show/new/create/...* the **reports** from **their city**
        and **all departments**.
        - The *regional auditor* **role** must only be able to *index/show* the **reports** of the **their city**
        and **all departments**.
        -  The *writer* **role** must be able to *index/show/new/create/...* the **reports** from **their city**
        and **their department.**
        - *John Doe* can simultaneously be a *regional auditor* in San Francisco and a *writer* 
        in New York for the 'Sports' department.
     - **Yes**. Good Match!
     - **No**. Sorry, Authz was built to support rules that involve **actions** being performed on **resources**.
     **Roles** are authorized to perform those actions on a **certain subest of those resources**, like the reports 
     that belong to New York and the Sports Department.

## Installation and Initial Setup

Add this line to your application's Gemfile:
```ruby
gem 'authz'
```

And then execute in your terminal:
```bash
$ bundle install
```

Then install and execute the Authz migrations by executing:
```bash
$ rails authz:install:migrations
$ rails db:migrate
```

Go to `app/models/` and open the model that manages your authenticated users (typically the `User` class) and: 
- `include` the `Authz::Models::Rolable` module which indicates Authz that `users` can be granted roles 
(see [Usage](#usage) for more info).
- Use the `authz_label_method` to define which method should Authz use to label each `user` inside the admin.
```ruby
class User < ApplicationRecord
  include Authz::Models::Rolable 
  authz_label_method :email
  # ...
end
```

Go to `app/controllers/application_controller.rb` and: 
- `include Authz::Controllers::AuthorizationManager`. This will make all controllers that inherit from the `ApplicationController`
capable of performing authorization. Alternatively, you may include this only in the controllers that you want.
- Optional: Authz will raise a `::NotAuthorized` exception whenever a user attempts
to perform a forbidden action. You may want to `rescue_from` it and define how to handle it gracefully.
- Optional: As a safeguard you can declare an `around_action :verify_authorized` which will raise an  `::AuthorizationNotPerformedError` 
exception if a developer forgets to authorize a controller action or to explicitly `skip_authorization` 
(see [Usage](#usage) for more info).
Alternatively, you may also do this inside each controller individually (particularly if you are using 
[devise](https://github.com/plataformatec/devise)).
- Optional: Authz assumes that your controllers have access to `current_user`. If this is not the case, simply
define a `authz_user` method that points to your current user.

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user! # Typical for devise
  include Authz::Controllers::AuthorizationManager
  rescue_from Authz::Controllers::AuthorizationManager::NotAuthorized, with: :unauthorized_handler
  # around_action :verify_authorized # Optional
  
  #... 

  private
  
  def unauthorized_handler
    msg = 'Ooops! It seems that you are not authorized to do that!'
    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, alert: msg }
      format.js{ render(js: "alert('#{msg}');") }
    end
  end

  def authz_user
    current_alien
  end
end
```

You are done with installation. The next step is to create some **Scoping Modules**.

## Usage
This library has 2 types of users: 
- Authorization admins (non-developers), who will manage the system once it is deployed.
- Developers, in charge of integrating the library into their application. 


### Usage for Authorization Admins
#### The Opinionated Structure
#### Cold-start
#### Managing the System
#### Keeping the System Healthy


### Usage for Developers


## License
Licensed under the MIT license, see the separate LICENSE.txt file.
