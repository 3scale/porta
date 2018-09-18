The following variables are available in every Liquid template:

- [provider][provider-drop] - all your services, plans and settings in one place
- [urls][urls-drop] - routes to built-in pages of the developers portal (login, signup etc.)
- [current_user][current-user-drop] - username, address and rights of the __currently logged-in user__
- [current_account][account-drop] - messages, applications and plans of the __currently logged-in user__
- [today][today-drop] - current date

[account-drop]: /p/admin/liquid_docs#account-drop "Account Drop"
[provider-drop]: /p/admin/liquid_docs#provider-drop "Provider Drop"
[urls-drop]: /p/admin/liquid_docs#urls-drop "URLs Drop"
[current-user-drop]: /p/admin/liquid_docs#currentuser-drop "Current User"
[today-drop]: /p/admin/liquid_docs#today-drop "Current User"

Built-in pages can also have other variables (they are mentioned in the CMS editor).
For example, an edit user form will have a `user` variable assigned while displaying
application details, and you can expect to have a variable named `application` as well.

The type of a variable (an important thing to know to use this reference) can be determined by putting
a `{% debug:help %}` tag into the page which will list all the available variables and types
in an HTML comment for you. Usually they can be guessed quite easily from the method or variable
name.

--------------------
