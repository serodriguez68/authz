# Authz
[![Build Status](https://travis-ci.com/serodriguez68/authz.svg?token=qXv4Wq7cPeFBwcByqvAc&branch=develop)](https://travis-ci.com/serodriguez68/authz)

**Authz** is an **opinionated** *almost*-**turnkey** solution for managing **authorization** in your Rails application.

Authz provides you with:
- An **authorization admin** interface that allows non-developers to configure and manage how authorization works for your app. 
The admin makes it very easy to answer questions like *"who can create top-secret reports"?* or *"what can John Doe do?"* 
- An easy-to-use API that allows developers to integrate *Authz* into their apps with **very little code** while providing
them with the tools they need. 
  - *"Can I make my views dynamic depending on the user's authorization?"* Yup!
  - *"Can I retrieve only the records the user has access to?"* Sure thing!
  - *"The role structure inside my organization changes frequently and I spend a lot of time updating the 'who-can-do-what' 
  code to keep up with the changes.'"* No worries. Use the admin to make the 
  tweaks you need, no code changes.
- An **opinionated** approach on how to structure your permissions that promotes clarity and maintainability.

Get a feel for **Authz** with this [video overview](TO-DO).


## Is Authz A Good Match For My Needs?
The authorization needs of different applications can vary widely and authorization requirements can get 
 indistinguishably close to business logic. 
 
 We recognize that **Authz** is not a good match for everyone. That is why we have designed the 
 following questions to help you assess if **Authz** is a good match for you.
 
1. Are you expecting to use **Authz** to authorize other applications **other** than the application you installed it in? (e.g. Using it as an authorization service for another app.)
    - **Yes**: Sorry, **Authz** is not for you.
    - **No**: Good match! 

2. Do you need to grant authorization considering factors other than **the action** that is being performed and **the resource**
it is being performed on?
    - For example:
        - Users must be denied access after 10 pm.
        - Users must be granted access based on their IP address.
        - Customers must be denied access when the transaction amount is greater than $5000.
    - **Yes**. If these types of rules are not very common in your app, you may still benefit from **Authz** provided that you
 take care of these cases yourself.  If they are common, you are better off checking out other projects like 
 [Pundit](https://github.com/varvet/pundit#policies) or [CanCanCan](https://github.com/CanCanCommunity/cancancan).
    - **No**: Good match!

3. Here are some examples of rules that can be configured in **Authz**. Do they look compatible with your needs?
    - Examples:
        - The *general director* **role** must be able to *index/show/new/create/...* the **reports** from **all cities**
        and **all departments**.
        - The *regional director* **role** must be able to *index/show/new/create/...* the **reports** from **their city**
        and **all departments**.
        - The *regional auditor* **role** must only be able to *index/show* (view) the **reports** of the **their city**
        and **all departments**.
        -  The *writer* **role** must be able to *index/show/new/create/...* the **reports** from **their city**
        and **their department.**
        - *John Doe* can simultaneously be a *regional auditor* in San Francisco and a *writer* in New York for the 'Sports' department.
     - **Yes**. Good Match!
     - **No**. Sorry, **Authz** seems not to work for you.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'authz'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install authz
```

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
