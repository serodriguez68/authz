# Authz
[![Gem Version](https://badge.fury.io/rb/authz.svg)](https://badge.fury.io/rb/authz)
[![Build Status](https://travis-ci.com/serodriguez68/authz.svg?token=qXv4Wq7cPeFBwcByqvAc&branch=master)](https://travis-ci.com/serodriguez68/authz)

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
Authz was built for applications that need a particular type of authorization which is very common 
and relatively simple. However, there are many other types of authorization rules that are out of 
the scope of this gem. The following questions will help you assess if Authz is a good match for you.
 
1. Are you expecting to use Authz to authorize other applications other than the application you installed it in? 
(e.g. Using it as an authorization service for another app)
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
     - **Yes**: Good Match!
     - **No**: Sorry, Authz was built to support rules that involve **actions** being performed on **resources**.
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

You are done with installation. The next step is to learn 
[how authorization rules work in Authz](#how-authorization-rules-work-in-authz).

## Usage
This library has 2 types of users and therefore there is a usage section for each:
- Authorization admins (non-developers), who will manage the system once it is deployed.
- Developers, in charge of integrating the library into their application. 

Before jumping into the details for each user type, it is very important that both
**developers** and **admins** understand how authorization rules are organised
in Authz.

### How Authorization Rules Work in Authz

In Authz `users` are granted one or many `roles`. Roles determine what a user is authorized to do, for example,
_John_ may only _edit blog post #1_ if he has been granted at least one role that is authorized to do so.
As a consequence, a `user` with no roles cannot do anything.

A `role` has **permission** to perform some actions on a certain **scope** (set) of instances.
[Permissions](#permissions) and [Scoping Rules](#scoping-rules) are the 
core components to determine if an **action** over a **resource** is authorized. 
The next figure illustrates this with an example.

<div align="center">
    <center>
        <img src="/readme_images/intro_to_structure.png" width="800"/>
    </center>
</div>

Lets dive a little deeper into [Permissions](#permissions) and [Scoping Rules](#scoping-rules).

#### Permissions
**Permissions** is the term we use to denote what a role can do. Permissions are actually organised in a
hierarchical structure designed to make the system intuitive and maintainable.

At the most fine-grained level we find the `ControllerActions`. Simply put, a `ControllerAction` is an 
_action_ that can be performed over a **resource class**; for example `Reports#update` indicates the action 
of updating resources of class _Report_.

_`ControllerActions` are a common thing in the developer world so don't worry, your developers will help you set-up 
this part._

`ControllerActions` are grouped into `BusinessProcesses`, each reflecting a _real-life_ process
that your business has. For example, a newspaper might have _"publish reports"_ and _"write reports"_ processes, each
requiring a different set of controller actions to get the job done.

`Roles` are granted the power to execute one or many `BusinessProcesses`. The next figure illustrates this with an
example. 

<div align="center">
     <center>
         <img src="/readme_images/permissions_hierarchy.png" width="800"/>
     </center>
 </div>
 
 We strongly recommend thinking about your authorization needs in terms of _actions_, _business processes_ and _roles_
 as this structure is easy to explain to other non-technical stakeholders.  However, you are more than welcome to
 bend this suggestion and use the `BusinessProcesses` and `Roles` as mere groupings in any way it makes sense for
 your business.


#### Scoping Rules
**Permissions** only define what a given role can do over certain **resource classes**. `ScopingRules` determine 
on which entities those permissions can be applied. This is better explained through an example.

Lets imagine that our multi-city newspaper application needs to implement the 
following authorization rules:
- As a _"New York Sports Editor"_ I need to be able to perform the _"publish report"_ and _"moderate comments"_ 
business processes only for the Sports department and for New York.
- As a _"San Fran Sports Editor"_ ... same as above... only for the Sports department and for San Francisco.
- As a _"Director"_ I need to be able to perform all business processes for all cities and for all departments.

The application for this newspaper needs multiple models to work: the `Cities` 
where it operates, the `Departments` in which the business is internally divided, the `Reports` they produce, 
the `Readers`that have paid for a subscription, the `Comments` the readers leave on the reports, etc. 
However, despite all these models, only the information about the `City` and the `Department` is relevant to
the authorization rules.

We call these classes **Scoping Classes** as they define the scope of the permissions granted to a role. For the
case of the "New York Sports Editor" role, the permissions to _"publish reports"_ and to _"moderate comments"_ are scoped 
down to `Reports` and `Comments` that belong to "New York" `City` and the "Sports" `Department`. We refer to these
as the **Scoping Rules**. The next figure illustrates how everything fits together. 

<div align="center">
     <center>
         <img src="/readme_images/how_everything_fits_together.png" width="800"/>
     </center>
 </div>
 
_Note to developers: if you are thinking "NY Sports Editor and SF Sports Editor, that looks like a unnecessary 
repetition..." take a look at the [Scopables](#scopables) section. It is simple to DRY this up, it's just 
easier to explain the concepts this way._

These **Scoping Classes** are typically exists inside the application's domain logic or they are easy enough to 
implement and fit nicely into the domain. 
**If you can't express you authorization rules in terms of Scoping Classes then Authz is probably 
not for you.**
   
### Usage for Authorization Admins
- 3 activities that admins do
#### Cold-start
#### Managing the System
#### Keeping the System Healthy


### Usage for Developers
#### Scopables
#### Controllers
#### Views


## Good Practices
- Visibility is important. Security holes are often related to people not understanding the system. 
- Minimum set of authorized stuff

## License
Licensed under the MIT license, see the separate LICENSE.txt file.
