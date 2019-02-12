<img src="/readme_images/authz_logo_v1_blue_green_2x.png" width="300"/>
  
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

Get a feel for **Authz** with this [live demo](https://authzcasestudy.herokuapp.com/).
<!--- TODO: Change link to video  --->

## Table of Content
- [Is Authz A Good Match For My Needs?](#is-authz-a-good-match-for-my-needs)
- [Requirements](#requirements)
- [Installation and Initial Setup](#installation-and-initial-setup)
- [Usage](#usage)
  * [How Authorization Rules Work in Authz](#how-authorization-rules-work-in-authz)
    + [Permissions](#permissions)
    + [Scoping Rules](#scoping-rules)
  * [Usage for Authorization Admins](#usage-for-authorization-admins)
    + [Cold-start Configuration](#cold-start-configuration)
    + [Business as Usual](#business-as-usual)
    + [Maintenance](#maintenance)
  * [Usage for Developers](#usage-for-developers)
    + [Scopables](#scopables)
    + [Controllers](#controllers)
      - [`authorize`](#authorize)
      - [`apply_authz_scopes`](#apply_authz_scopes)
    + [Views](#views)
      - [`authorized_path?`](#authorized_path)
      - [`authz_link_to`](#authz_link_to)
    + [Programmatic Interaction with Authz](#programmatic-interaction-with-authz)
- [Performance and Caching](#performance-and-caching)
  * [In-request caching](#in-request-caching)
  * [Cross-request caching](#cross-request-caching)
  * [Fragment and Russian Doll caching](#fragment-and-russian-doll-caching)
- [Common Problems and Solutions](#common-problems-and-solutions)
- [License](#license)

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
        - The *regional auditor* **role** must only be able to *index/show* the **reports** from **their city**
        and **all departments**.
        -  The *writer* **role** must be able to *index/show/new/create/...* the **reports** from **their city**
        and **their department.**
        - *John Doe* can simultaneously be a *regional auditor* in San Francisco and a *writer* 
        in New York for the 'Sports' department.
     - **Yes**: Good Match!
     - **No**: Sorry, Authz was built to support rules that involve **actions** being performed on **resources**.
     **Roles** are authorized to perform those actions on a **certain subest of those resources**, like the reports 
     that belong to New York and the Sports Department.

[Back to table of content](#table-of-content)

## Requirements
- Rails >= 5.0 using `ActiveRecord` on a relational database.
- Your app already has an authentication mechanism like [Devise](https://github.com/plataformatec/devise).
- Optional: Your preference of caching technology through `ActiveSupport::Cache`.

## Installation and Initial Setup

Add this line to your application's Gemfile:
```ruby
gem 'authz'
```

And then execute in your terminal:
```bash
$ bundle install
```

Then install Authz executing:
```bash
$ rails g authz:install
# => config/initializer/authz.rb gets created
# => The authz migrations are installed
$ rails db:migrate
```

Seed Authz's tables with the data required to control access to the Authorization Admin.
This will create a [Business Process](#permissions) in the `Authz::BusinessProcesses` table.
Any role that is granted that business process will get full access to the Authorization Admin.
- Later, you will also probably want to run this in production to configure it. 
See [Cold Start Configuration](#cold-start-configuration) for more details.
 ```bash
$ rails authz:seed_admin
```

Go to `config/initializer/authz.rb` and configure:
```ruby
unless Rails.configuration.eager_load
  # The scopables location
  Dir[Rails.root.join('app/scopables/**/*.rb')].each{ |f| require f }
end
Authz.configure do |config|
  # The method that Authz should use to force authentication into the Authorization Admin
  config.force_authentication_method = :authenticate_user!
  # The method used to access the current user
  config.current_user_method = :current_user
  # ...
  # config.cross_request_caching = true 
end
```

Go to `config/routes.rb` and mount the Authz engine admin on the path of your choice:
```ruby
Rails.application.routes.draw do
  mount Authz::Engine => '/authz', as: 'authz'
  # ...
end
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
The admin will also use this handler when unauthorized access is attempted, but only if placed inside the `ApplicationController`.
- Optional: As a safeguard you can declare an `around_action :verify_authorized` which will raise an  `::AuthorizationNotPerformedError` 
exception if a developer forgets to authorize a controller action or to explicitly `skip_authorization` 
(see [Usage](#usage) for more info).
Alternatively, you may also do this inside each controller individually (particularly if you are using 
[devise](https://github.com/plataformatec/devise)).

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user! # Typical for devise
  include Authz::Controllers::AuthorizationManager
  rescue_from Authz::Controllers::AuthorizationManager::NotAuthorized, with: :unauthorized_handler
  # around_action :verify_authorized # Optional
  
  #... 

  private
  # Note that the redirect uses main_app.(something).
  # main_app is must be used to avoid ambiguity between
  # your app and the engines you use if there are route helpers 
  # with the same name (like root_url)  
  def unauthorized_handler
    msg = 'Ooops! It seems that you are not authorized to do that!'
    respond_to do |format|
      format.html { redirect_back fallback_location: main_app.root_url, alert: msg }
      format.js{ render(js: "alert('#{msg}');") }
    end
  end
end
```

You are done with installation. The next step is to learn 
[how authorization rules work in Authz](#how-authorization-rules-work-in-authz). If you already know this, go to the
[Scopables](#scopables) section.

[Back to table of content](#table-of-content)

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

[Back to table of content](#table-of-content)

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

[Back to table of content](#table-of-content)

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
down to `Reports` and `Comments` that belong to "New York" `City` and the "Sports" `Department`. 
In Authz terminology, we say that a “New York Sports Editor” is authorized to do any of his granted **permissions** 
only on resources that are within his scope, which is defined by his configured **Scoping Rules**:
- `ScopableByCity = 'New York`
- `ScopableByDepartment = Sports` 

The next figure illustrates how everything fits together. 


<div align="center">
     <center>
         <img src="/readme_images/how_everything_fits_together.png" width="800"/>
     </center>
 </div>
 
_Note to developers: if you are thinking "NY Sports Editor and SF Sports Editor, that looks like a unnecessary 
repetition..." take a look at the [Scopables](#scopables) section. It is simple to DRY this up, it's just 
easier to explain the concepts this way._

These **Scoping Classes** typically exists inside the application's domain logic or are easy enough to 
implement and fit nicely into the domain. 
**If you can't express your authorization rules in terms of Scoping Classes then Authz is probably 
not for you.**

[Back to table of content](#table-of-content)
   
### Usage for Authorization Admins 

Authz comes with a built-in authorization GUI from which admins can configure everything related to authorization. 
The GUI can be accessed through a URL/path configured by the developers.

There are 3 types of activities that admins do through the GUI: _cold-start configuration, 
business as usual and maintenance._


#### Cold-start Configuration
Cold-start makes reference to configuring all the permissions, scoping rules and roles on a brand new Authz installation.

For teams that are integrating Authz into an existing live project we recommend doing the cold-start configuration 
using a rake task, since they probably can’t afford to have all users locked out while the 
admin manually configures everything through the GUI. More information on how to do this on: 
[Programmatic Interaction with Authz](#programmatic-interaction-with-authz).

Teams can also opt to use the GUI to manually configure everything. Authz uses itself to authorize 
the access to the GUI, so the “first ever” admin needs to be granted permission to access the GUI by a developer 
through the console. Authz provides a the `rails authz:seed_admin` rake task to automatically seed everything 
needed to access the GUI (more information on the [Installation Section](#installation-and-initial-setup)).

[Back to table of content](#table-of-content)

#### Business as Usual
During _“business as usual”_ an admin will make changes to the authorization configuration to keep up with the business’ 
needs, like granting, creating and revoking roles.

The GUI provides the admins full control of the authorization system without requiring any code modifications and 
re-deployments. Through the GUI admins can:
- Create, view, update and delete controller actions, business processes, scoping rules and roles.
- Grant and revoke roles to users.

The admin also makes it very easy to answer questions like _“who can cancel orders?”_ or _“what can John do?”_.

<div align="center">
     <center>
         <img src="/readme_images/admin_high_visibility.png" width="800"/>
     </center>
</div>

[Back to table of content](#table-of-content)

#### Maintenance
The authorization configuration will need maintenance as developers make changes to the codebase. 
In particular, maintenance is needed when developers add/remove **controller actions** from the application 
or add/remove/change the **scopables** or **keywords** for the **scoping rules**.

The GUI’s main dashboard detects differences from the current in-database configuration and the codebase, 
and suggests the adjustments that need to be done. However, nothing replaces good communication between the developers 
and the authorization admins.

<div align="center">
     <center>
         <img src="/readme_images/admin_dashboard.png" width="800"/>
     </center>
 </div>


[Back to table of content](#table-of-content)

### Usage for Developers
The authorization logic bits inside your app typically live in 3 places: [Scopables](#scopables), 
[Controllers](#controllers) and [Views](#views). You may also interact with the Authz models directly.

#### Scopables
This is the first thing to do if you have just installed the gem.

Start by identifying which are the [Scoping Classes](#scoping-rules) inside your app that you need to meet your 
authorization needs. For the rest of this section we will carry on with our newspaper example where the scoping classes
are `City` and `Department`.

A **Scopable** is a plain old ruby module that extends from `Authz::Scopables::Base`. *Scopables* are used to indicate 
to Authz which keywords are available for the configuration of `ScopingRules` and what do they mean.
 
Given that `City` is a **scoping class**, we need to create a `ScopableByCity` module (note the naming convention) 
that must define two methods:
- `.available_keywords` must return an array of strings with the available keywords for scoping by city.
- `.resolve_keyword` must translate the given keyword into an array of the ids of the cities that are available for that
keyword.  The method must take 2 arguments: `keyword` and `requester` (the instance of the user that is being 
authorized).
    - If you add `+[nil]` to the array of ids resolved, you allow the bearer of the keyword to have access to
    resources that are NOT associated with any city, like reports or comments with no city.
- You can use the special keyword `'All'`, which will give the bearer access to all cities. You don't need to 
resolve `All` in your `#resolve_keyword` method.

We recommend creating an `app/scopables` directory to place the scopables, but you can put them wherever you want.
Just remember to adjust the `authz.rb` initializer accordingly.

```ruby
module ScopableByCity
  extend Authz::Scopables::Base
  
  # It must return an array of strings
  def self.available_keywords
    # You can query the DB to generate the available keywords
    City.all.pluck(:name) + ['All']
    
    # ... or you can define some custom keywords that make sense for your needs
    %w[high-altitude low-altitude]
    
    # ... many applications allow some users to access only resources "they own"
    # e.g. access to "my cities"
    %w[mine All]
  end
  
  # It must return an array if ids
  def self.resolve_keyword(keyword, requester)
    # If your keyword is an attribute, you can resolve it like this  
    City.where('LOWER(name) IS ?', keyword.downcase).pluck(:id) + [nil]
   
    # ... Or if it is something else
    if keyword == 'high-altitude'
     City.get_high_altitude.pluck(:id)
    elsif keyword == 'low-altitude'
      City.get_low_altitude.pluck(:id)
    end 
    
    # ... You can even use the requester to resolve using anything in your domain
    if keyword == 'mine'
      requester.cities.pluck(:id) 
    end
  end

end
``` 

The next step is to indicate to Authz which models of your app need to be scoped by city for authorization purposes.
For example, if we want to grant or deny authorization for `Reports` based on the  city scoping rule, we must
`include` the `ScopableByCity` in the `Report` class.
- The `Report` class must have an active record association to `City`. It can be any type of association,
including `through: :other_model`.
- Authz will use automatically look for associations based on the name of the Scopable (`:city` and `:cities` in
this case). If your association name is different or if you have both `:city` and `:cities` associations, indicate the
name of the association to use using `#set_scopable_by_city_association_name`.

```ruby
class Report < ApplicationRecord
  belongs_to :city
  include ScopableByCity
  # set_scopable_by_city_association_name :ciudad
end
```

You might want to determine access to instances of a class based on more than one `ScopingRule`. For example, for
reports we want to grant access only if the requester has the correct `City` and `Department`.

This is very easy to achieve. Create a `ScopableByDepartment` module and include it in the `Report` class.
```ruby
class Report < ApplicationRecord
  belongs_to :city
  belongs_to :department
  include ScopableByCity
  include ScopableByDepartment
end
```

The **scoping classes** like `City` and `Department` are trivially scopable by themselves. For example, only users
with access to the `City` instance 'New York' will be able to perform actions on it (like update it).
```ruby
class City < ApplicationRecord
  # No association needed of course...
  include ScopableByCity 
end
```

Note that for a given role, the defined scoping rules apply equally on all models. For example, given that the
'ny sports editor' role has a City scoping rule of 'New York' and a Department scoping rule of 'Sports' these rules
will apply whenever a 'ny sports editor' is trying to act upon a `Report` or `Comment`. If for some reason, when
dealing with `Reports` you want to apply the 'New York' keyword and when dealing with `Comments` you want to apply
the 'San Francisco" keyword, you need to define 2 different roles (**they probably are 2 different roles**).

<!--- TODO: Modify this if we add the functionality of default keywords and overrides for specific actions  --->
[Back to table of content](#table-of-content)

#### Controllers

##### `authorize`

The `authorize` method is used to perform authorization on a controller action. You must supply the instance
on which the action is trying to be executed using the `using: @report` argument.
 
```ruby
class ReportsController < ApplicationController
  #...
  def show
    @report = Report.find(params[:id])
    authorize using: @report
    # Will raise Authz::Controllers::AuthorizationManager::NotAuthorized
    # if not authorized 
  end
end
```

Authz will check if the current user has any role that allows him to perform the action `Reports#show` on the instance
`@report` taking into account the role's *Scoping Rules*. Note that the controller and action name are automatically
inferred.

<!--- TODO: If we relax the authorize method to allow for passing custom actions, put that here  --->

For some actions, we really don't have a sensible instance to use for authorization. In these cases we can
use the `skip_scoping: true` argument to perform authorization based on the permitted actions only.

```ruby
class ReportsController < ApplicationController
  #...
  def new
     authorize skip_scoping: true
     @report = Report.new
  end
end
```

For the most part, we can keep the traditional RESTful controller action coding style and just include `authorize`. 
Notable exceptions are actions that attempt to `#update` or `#create` an instance since we want to 
make sure that the instance is within the **scoping rules** _after_ it has been saved. For example, a 
'ny sports writer' should not be able to update the city of a 'New York' `report` to 'San Francisco'. 

In simple cases we don't have to do much as Rails handles this through in memory association proxies:
- `#create` actions keep their RESTful style.
- In `#update` actions we can use `.assign_attributes` to change the instance in memory and authz
will verify it with the new information.
```ruby
def create
    @report = Report.new(report_params)
    @report.user = current_user
    authorize using: @report

    if @report.save
      redirect_to @report, notice: 'Report was successfully created.'
    else
      render :new
    end
end

def update
    @report.assign_attributes(report_params)
    authorize using: @report
    if @report.save
      redirect_to @report, notice: 'Report was successfully updated.'
    else
      render :edit
    end
 end
```

In complex cases, where we have to save the `@report` **first** to determine the associated `City`, 
we can wrap our controller action inside a database transaction that will be
rolledback if `authorize` raises an exception. Examples of these _'complex cases'_ are:
- Callbacks that affect the instance's association to the **scoping classes** during the `save` lifecycle.
- Deep associations that rely on the creation of many intermediate instances to find out the resulting
associated `City`.
- Overriding of `ActiveRecord`'s `update`, `save`, `create` or similar methods that manipulate the instance's
association to the **scoping classes**.
- Any other path / quirk / hack that does not allow `ActiveRecord` to pick up the association in memory.   

```ruby
def update
    ActiveRecord::Base.transaction do
        @report = Report.find(params[:id])
        if @report.update(report_params)
          authorize using: @report # Raises if not authorized
          redirect_to @report, notice: 'Report was successfully updated.'
        else
          render :edit
        end
     end
 end
``` 
 
[Back to table of content](#table-of-content)
 
##### `apply_authz_scopes`
We can scope down the retrieval of collections to comply  with the user's scoping rules using the 
`apply_authz_scopes` method.

For example, if we want to retrieve the `Reports` that are within the `current_user`'s scoping rules for
`City` and `Department`:

```ruby
def index
    authorize skip_scoping: true
    @reports = apply_authz_scopes(on: Report) # Returns an AR relation
                 .includes(:user, :city, :clearance)
                 .order('cities.name ASC')
end
```
`apply_authz_scopes` takes a `class` or an  `ActiveRecord::Relation` and applies the applicable scoping rules
on top of the given argument. The method returns an `ActiveRecord::Relation` so it can be chained with other
query methods.

`apply_authz_scopes` is also available as a view helper in case you need to use it inside a view. 

[Back to table of content](#table-of-content)

#### Views

##### `authorized_path?`
The `authorized_path?` view helper can be used to check if the `current_user` is authorized for a given _url/path_.
Under the hood, Authz will ask your `router` for the controller and action in charge of resolving the given _url/path_ 
and use that for determining authorization. 

Similar to the `authorize` method above, we need to provide either a `using: instance` or `skip_scoping: true` if no
sensible instance exists.

`authorized_path?` can be used to conditionally display parts of the view, most commonly a  `link_to`.

```erb
<%= link_to 'Edit', edit_report_path(report) if authorized_path?(edit_report_path(report), using: report) %>
<%= link_to 'Destroy', report, { data: { confirm: 'Are you sure?' }, method: :delete } if authorized_path?(report_path(report), method: :delete, using: report) %>
<%= link_to('Create New Report', new_report_path) if authorized_path?(new_report_path, skip_scoping: true) %>
```    

[Back to table of content](#table-of-content)

##### `authz_link_to`
The pattern of rendering a link only if the `current_user` is authorized to use it, is so common that it deserves it's
own helper.

`authz_link_to` takes the same 3 arguments than Rail's `link_to` helper (i.e. `name, options = {}, html_options = {}`). 
Additionally you need to provide the `using: instance` to use against the scoping rules 
or `skip_scoping: true` if no sensible instance exists.

```erb
<%= authz_link_to 'Edit', edit_report_path(report), {}, using: report %>
<%= authz_link_to 'Destroy', report, { data: { confirm: 'Are you sure?' }, method: :delete }, using: report %>
<%= authz_link_to 'Create New Report', new_report_path, { class: 'button' }, skip_scoping: true %>
# Note that we are explictly wrapping the 3rd argument in {} to avoid ambiguity in the params.
# If you get an 'unknown keyword: class' error, it's caused by this.
```
[Back to table of content](#table-of-content)

#### Programmatic interaction with Authz
Everything that can be done through the admin GUI can also be done programmatically. 
You can interact with Authz’s models in the exact same way as you would interact with any `ActiveRecord` class. 

The models you probably want to interact with are: `Authz::ConrollerAction`, `Authz::BusinessProcess`, 
`Authz::Role`, `Authz::RoleGrant` and `Authz::ScopingRule`. 

You can also call `user.roles` to get the roles associated to a user. 

If for some reason you want to reference a specific `BusinessProces` or `Role` from your code,
you can do so through the `code` attribute. `code` is automatically set as the snake case
 of the `name` upon creation (unless you specify otherwise) and can't be changed from the GUI
 (so your code does not break if the name is changed).
 
```ruby
Authz::Role.find_by(code: 'foo')
Authz::BusinessProcess.find_by(code: 'bar')
```
[Back to table of content](#table-of-content)


## Performance and Caching
Dynamic views based on the `current_user`'s authorization privileges will add some calls to your
database as part of the authorization resolution process. The effect of these additional calls 
can be significant in applications with highly dynamic views and requires special attention.

Authz implements 3 different caching strategies to meet production-grade performance needs.

### In-request caching
Authz uses [Active Record's SQL caching](https://guides.rubyonrails.org/caching_with_rails.html#sql-caching)
to guarantee that any query that is repeated during the request-response cycle is not re-run against your database.
This is a built-in feature and as developer you don't have to do anything to benefit from it.

_Some developers like to silence the logging from Active Record's CACHE as it can
pollute your logs. [Learn how to to that here.](https://github.com/serodriguez68/authz/wiki/Disable-Logging-of-CACHEd-SQL-queries-in-Rails)_

[Back to table of content](#table-of-content)

### Cross-request caching
Cross-request caching allows Authz to build a cache that can be re-used across multiple requests,
reducing sharply the number of authorization related calls to your database.

Authz's cross-request caching uses Rails' native `ActiveSupport::Cache`, which allows you
to choose the caching store technology of your preference.

To enable this feature:
1. Configure caching as you would normally do for any Rails app. Read the official
[Rails Guide](https://guides.rubyonrails.org/caching_with_rails.html) to find out how to do this.
2. Make sure you have enabled caching in development in order to try this feature locally. 
This can be toggled by running `rails dev:cache` on your terminal.
3. Go to `config/initilizers/authz.rb` and set `config.cross_request_caching = true`.

[Back to table of content](#table-of-content)

### Fragment and Russian Doll caching
_Note:_

_There are only two hard things in Computer Science: cache invalidation and naming things. 
-- Phil Karlton_

_Many small and medium apps can work perfectly fine with cross-request caching.
Correct cache invalidation for Fragment and Russian Doll caching can be difficult to 
achieve so don't fall prey to premature optimization._

[Fragment and Russian Doll caching](https://guides.rubyonrails.org/caching_with_rails.html#fragment-caching) are
common caching techniques where a fragment of pre-computed HTML is cached under a key. This key is used for retrieving
the cached HTML instead of re-computing the fragment.

The cornerstone of this type of caching is [key-based cache expiration](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
, which means that they key must change whenever something that impacts the fragment's content
changes.  The key change will force the re-computation of the fragment, that will be stored in the cache under
the new key.

Authorization information will most likely be a __part__ of your keys whenever the fragment has content that
depends on authorization (e.g. it contains `authz_link_to` or `authorized_path?`). You can use the
`#roles_cache_key` method on your user instances to get a key that automatically changes whenever their role
definitions have been modified.
 
Note that `#roles_cache_key` only contains information from **the roles** and **does
NOT** contain information about the user. This means that if users `alice` and `bob` are both
_NY Sports Editor_ and _SF Sports Writer_:
- `alice.roles_cache_key` will contain information of both roles and the key will look something like this: 
`"authz/roles/4-20190125101536064307/authz/roles/6-20190125084604920649"`
- `bob.roles_cache_key` will return the same key. Therefore, if the fragment key 
does not depend on anything else, `bob` will re-use the cached information generated by `alice`. 
- Whenever any of the role definitions change, the returned key will change,
invalidating all fragments that depended on the role (e.g. a new business process is assigned to _NY Sports Editor_).
- If you need to make the fragment key depend on anything else, you need to include that yourself.

A typical fragment caching situation would look like this:

```slim
 - @reports.each do |report|
        - cache [report, current_user.roles_cache_key]
          tr
            td = report.id
            td = report.user.email
            td = report.department.try :name
            td = report.city.try :name
            td = report.title
            td = report.body.truncate(100)
            td = authz_link_to 'Show', report, using: report
            td = authz_link_to 'Edit', edit_report_path(report), using: report
            td = authz_link_to 'Destroy', report, { data: { confirm: 'Are you sure?' }, method: :delete }, using: report
```

**Gotchas**

The fact that 2 users have the same roles (and therefore the same `#roles_cache_key`) does not necessarily mean that
they should be able to share cached fragments. For example, lets imagine that in our multi-city newspaper app we decide
not to create separate `Roles` for each department (_NY Sports Editor, NY Politics Editor_). Instead we just
create _NY Editor_ `role`, storing in the `departmets_users` table the mapping between users and departments,
and create a _"mine"_ keyword inside `ScopableByDepartment`. 

```ruby
module ScopableByDepartment
  extend Authz::Scopables::Base
  
  def self.available_keywords
    %w[mine All]
  end
  
  def self.resolve_keyword(keyword, requester)
    if keyword == 'mine'
      requester.departments.pluck(:id) 
    end
  end
end
```

In this case, the _NY Editor_ role will have configured the _"mine"_ keyword for it's `ScopableByDepartment` rule.
However, _"mine"_ can resolve to different departments for `alice` and `bob` despite both being  _NY Editors_. As 
a consequence, we need to include information about the departments in addition to `#roles_cache_key`in the fragment
keys.

[Back to table of content](#table-of-content)


## Common Problems and Solutions
- When linking from your app into the Authz Admin, make sure you use the `root_url` helper and NOT the `root_path`.
If you don't, you will get an `ActionController::RoutingError No route matches...`. In other words, 
if you mounted Authz `as: authz` in your router, use: 
```authz_link_to 'Authorization Admin', authz.root_url, skip_scoping: true```.
 
[Back to table of content](#table-of-content)

## License
Licensed under the MIT license, see the separate LICENSE.txt file.

[Back to table of content](#table-of-content)