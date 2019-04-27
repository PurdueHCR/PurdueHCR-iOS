# Purdue HCR Test Plan


## User Creation Tests
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


## Sign In Tests
|  # 	|   Test Name	|   Test Description	|   Success Conditions	|
|---	|:-:	|:-:	|:-:	|
| 2.1 | Invalid Email | While signing in, enter an email address that does not connect to an account. | Could Not Find User Error |
| 2.2 | Invalid Password | While signing in, enter a valid email address, but enter the incorrect password. | Incorrect Password Error |


## Resident Point Submission Tests
|  # 	|   Test Name	|   Test Description	|   Success Conditions	|
|---	|:-:	|:-:	|:-:	|
| 3.1 | Successful Self-Submit Point Submission | As a resident, select a point type, enter a description and submit the point. Log in as an RHP, approve the point. | The resident's and the house's points sucessful increment and all notifications are success notifications.|
| 3.2 | Missing Resident's Description | As a resident, attempt to submit a point without entering a description. | Verify that there was an error notification and that there is no point request on the RHP approval page. |
|3.3| Self-Submit Over Character Limit | As a resident, select a point type and enter a description that is 1 character longer than the character limit. | Make sure that the app does not prevent the user from typing that many characters, but verify there is an on screen element that notifies the user that they have typed to many characters, and if they hit submit, there is a Too Many Characters Error.|
|3.4| Successful Single Use QR Code Scan | As an RHP create a single use QR code. Log in as a resident, and scan the QR code. Then scan the QR code again. | Verify that the first scan succeeds and adds points to the user and the house. Then verify the second scan results in a Already Scanned Error. |
|
