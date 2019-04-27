#

|  # 	|   Test Name	|   Test Description	|   Success Conditions	|
|---	|:-:	|:-:	|:-:	|
|  1.1 	|  Missing information 	|   Attempt to create a user, but input none of the information.	|   Incomplete Form Error	|
|   1.2	|  Missing Email 	|   While creating a user, input every field except for the email field.	|  Incomplete Form Error 	|
|   1.3	|   Invalid Email	|   While creating a user, enter an email address that is not in the correct format for an email.	|   Invalid Email Error	|
|  1.4 	|   Invalid Purdue Email	|   While creating a user, enter an email address that is in the valid format but is not a purdue.edu.	|   Invalid Email Error	|
|   1.5	|   Missing Name	|   While creating a user, input all information except for the name.	|  Incomplete Form Error 	|
|   1.6	|   Invalid Name Test	|   While create a user, put in only the first name of a user.	|   Invalid Name Error	|
|  1.7 	|  Multiple Name Test 	|  While creating a user, enter a name with three words, fill out other information correctly, but put in an invalid house code. 	|  Invalid House Code Error 	|
|   1.8	|   Missing Password	|  While creating a user, put in all information aside from the password. 	|   Incomplete Form Error	|
|   1.9	|   Invalid Password	|  While creating a user, enter a password that does not meet out password requirements. 	|  Invalid Password Error 	|
|  1.10 	|   Missing Verify-Password	|   While creating a user, put in all information aside from the verify password.	|  Incomplete Form Error 	|
|   1.11	|  Incorrect Verify-Password 	|   While creating a user, enter a verify-password that does not match the password field.	|  Mismatching Password Error 	|
|   1.12	|   Missing User Code	|  While creating a user, put in all information aside from the User Code. 	|   Incomplete Form Error	|
|   1.13  |  Invalid User Code  |  While creating a user, enter an invalid user code. | Invalid Code Error |
