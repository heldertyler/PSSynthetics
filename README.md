## PSSynthetics
A PowerShell Module for Performing Synthetic Web Transactions

## Purpose
PSSynthetics is a PowerShell module that allows you to similate a user using a website. A few use cases for this module:
- Testing web site functionality after down time or maintenance 
- Running through a transaction when working on bug fixes
- Possibly a super low budget synthetic user monitoring system. (Run as shedule task and send email if transactions fails)

## How It Works
PSSynthetics works by reading an XML file (transaction) and then carries out the transaction using the Internet Explorer Com Object. Currently the following actions are supported (Several more actions coming soon):
- clickElementByID or clickElementByTag (useful for clicking on element id's or tags, ie. clicking on logon button, images, etc...)
- Navigate to web pages
- Validate (Useful for verifing that the page you are on is the page you were expecting)
- valueByElementID (useful for settings values in forms, ie. username/password forms, search bars, etc...)

## Challenges
The biggest challenge for this module is error handling, since PowerShell and Internet Explorer are two independent applications that are unaware of each other. HTTP status codes are not exposed to the internet explorer com object and there is no easy way of detecting when you reach an error page on a website (from a broad sence). One solution to get around this is to add more validation step to verify that eveyrthing is running correct and from the expected pages.

## Documentation 
Please see [wiki](https://github.com/heldertyler/PSSynthetics/wiki)
