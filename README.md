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

Get a feel for **Authz** with this [live demo](https://authzcasestudy.herokuapp.com/).
<!--- TODO: Change link to video  --->

## Table of Content
- [Is Authz A Good Match For My Needs?](#is-authz-a-good-match-for-my-needs)
- [Installation and Initial Setup](#installation-and-initial-setup)
- [Usage](#usage)
  * [How Authorization Rules Work in Authz](#how-authorization-rules-work-in-authz)
    + [Permissions](#permissions)
    + [Scoping Rules](#scoping-rules)
  * [Usage for Authorization Admins](#usage-for-authorization-admins)
    + [Cold-start](#cold-start)
    + [Managing the System](#managing-the-system)
    + [Keeping the System Healthy](#keeping-the-system-healthy)
  * [Usage for Developers](#usage-for-developers)
    + [Scopables](#scopables)
    + [Controllers](#controllers)
      - [`authorize`](#authorize)
      - [`apply_authz_scopes`](#apply_authz_scopes)
    + [Views](#views)
      - [`authorized_path?`](#authorized_path)
      - [`authz_link_to`](#authz_link_to)
- [Authorization Good and Bad Practices](#authorization-good-and-bad-practices)
  * [Good Practices](#good-practices)
  * [Bad Practices](#bad-practices)
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

[Back to table of content](#table-of-content)

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
$ rails authz:install
# => config/initializer/authz.rb gets created
# => The authz migrations are installed
$ rails db:migrate
```

Go to `config/initializer/authz.rb` and configure:
```ruby
Authz.configure do |config|
  # The method that Authz should use to force authentication to the Authorization Admin
  config.force_authentication_method = :authenticate_user!
  # The method used to access the current user
  config.current_user_method = :current_user
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

These **Scoping Classes** typically exists inside the application's domain logic or are easy enough to 
implement and fit nicely into the domain. 
**If you can't express you authorization rules in terms of Scoping Classes then Authz is probably 
not for you.**

[Back to table of content](#table-of-content)
   
### Usage for Authorization Admins 
TODO: we are working on this... stay tuned
- 3 activities that admins do
#### Cold-start
#### Managing the System
#### Keeping the System Healthy

[Back to table of content](#table-of-content)

### Usage for Developers
The authorization logic bits inside your app typically live in 3 places: [Scopables](#scopables), 
[Controllers](#controllers) and [Views](#views). 

#### Scopables
This is the first thing to do if you have just installed the gem.

Start by identifying which are the [Scoping Classes](#scoping-rules) inside your app that you need to meet your 
authorization needs. For the rest of this section we will carry on with our newspaper example where the scoping classes
are `City` and `Department`.

A **Scopable** is a plain old ruby module that extends from `Authz::Scopables::Base`. *Scopables* are used to indicate 
to Authz which keywords are available for the configuration of `ScopingRules` and what do they mean.
 
Given that `City` is a **scoping class**, we need to create a `ScopableByCity` module (note the naming convention) 
that must define two methods:
- `#available_keywords` must return an array of strings with the available keywords for scoping by city.
- `#resolve_keyword` must translate the given keyword into an array of the ids of the cities that are available for that
keyword.  The method must take 2 arguments: `keyword` and `requester` (the instance of the user that is being 
authorized).
    - If you add `+[nil]` to the array of ids resolved, you allow the bearer of the keyword to have access to
    resources that are NOT associated with any city, like reports or comments with no city.
- You can use the special keyword `'All'`, which will give the bearer access to all cities. You don't need to 
resolve `All` in your `#resolve_keyword` method.

We recommend creating an `app/scopables` directory to place the scopables, but you can put them wherever you want.

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

Authz will check if the current user has any role that allows him to do the action `Reports#show` on the instance
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
Under the hood, Authz will ask our `router` for the controller and action in charge of resolving the given _url/path_ 
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
The pattern of rendering a link only if the `current_user` is authorized to use it is so common that it deserves it's
own helper.

`authz_link_to` takes the same 3 arguments than Rail's `link_to` helper (i.e. `name, options = {}, html_options = {}`). 
Additionally you need to provide the `using: instance` to use against the scoping rules 
or `skip_scoping: true` if no sensible instance exists.

```erb
<%= authz_link_to 'Edit', edit_report_path(report), {}, using: report %>
<%= authz_link_to 'Destroy', report, { data: { confirm: 'Are you sure?' }, method: :delete }, using: report %>
<%= authz_link_to 'Create New Report', new_report_path, { class: 'button' }, skip_scoping: true %>
```
[Back to table of content](#table-of-content)

## Authorization Good and Bad Practices
A non exhaustive list of generally accepted authorization wisdom and things we've learned from using Authz ourselves:

### Good Practices 
- **Principle of Least Privilege**: Users should have the minimal set of permissions required to perform 
their duties on the application.
- **Closed by Default / Fail-Safe Systems**: deny access to resources unless otherwise stated. 
“Blacklisting” type of permissions should only be used as an optimisation on top of a fail-safe system. This is why
`around_action :verify_authorized` is a good idea.
- **Visibility Is Important**: Strive to design a permission and scoping structure that is easily understandable
by all human beings managing the authorization system. Answering questions like _'who can edit reports'_ and _'what
can user 1234 do'_ should be straightforward. Security holes are often related to misconfiguration due to complexity.
- **Know the Trade-offs**: As with most of things in engineering, there is no "best" solution for all authorization
problems; it's up to you to choose the right tool for YOUR job. In our opinion the most important trade-off is driven
by the _"rule resolution time"_ of your authorization strategy/library. The extreme points of this continuum are 
pure **Runtime resolution** and pure **Static resolution**, with most systems falling somewhere in the middle.
    -  **Runtime resolution** means that when a _user_ performs a request to perform an _action_ over a _resource_ 
    given a certain _context_, the system executes some code at runtime to decide whether the user can be granted access.
    - **Static Resolution** means that the user access is fully pre-defined and once a user request arrives it can be 
    resolved by simply “reading” from the defined permissions (e.g. querying a database).
    - For reference **Authz** takes a hybrid approach in which permissions are **statically defined**, and the degree
     of **runtime resolution** for scoping rules can be chosen by developers according to their needs. We believe this
     is a happy medium that is able to support many use cases while keeping the benefits of visibility and configurability.

<div align="center">
     <center>
         <img src="/readme_images/rule_resolution_time_tradeoffs.png" width="700"/>
     </center>
 </div>  

### Bad Practices
- **Client-Side Authorization** does not exist (period). If anything, it can be included 
as a usability improvement.
- **Security Through Obscurity**: Any authorisation system that relies on the user not knowing certain information to 
guarantee security is not viable. For example, using obfuscated URL links to make it harder for attackers to guess 
a customer’s invoice number.
- **Leave Authorization for Later**: _'let's develop the whole thing and we will think about authorization later'_.
This sucks but it's the truth. Almost everything you code requires some type of authorization and therefore authorization 
code quickly gets everywhere. If you just 'wing it' with a couple of boolean flags in the `User` model you are 
almost guaranteed to have a painful re-write. 

[Back to table of content](#table-of-content)

## License
Licensed under the MIT license, see the separate LICENSE.txt file.

[Back to table of content](#table-of-content)