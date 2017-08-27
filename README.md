## PSSynthetics - PowerShell Browser Automation
A PowerShell Module for Performing Synthetic Web Transactions

## Purpose
PSSynthetics is a PowerShell module that was created to provide similar functionality to selenium but a much slimmer version. PSSynthetics only supports browser automation through Internet Explorer and as this project becomes more mature should cover 90-95% of selemiums functionality. The following is what make this like selenium but slimmer:

1. There is no need to write/compile code or create an apache ant build for reporting. This module works by reading formatted xml files and carries out the transaction in internet explorer, once complete a powershell object is output.
2. Powershell is built-in to all recent versions of windows so there is no need to install java, python, etc...
3. No need to ensure third party browsers are installed as this only suppots internet explorer which is built-in to windows.

## How It Works
PSSynthetics works by reading an XML file (transaction) that contains the steps to perform and then carries out the steps in internet explorer in the order they are placed in the XML file. See wiki for step by step instructions for creating a transaction file.

## Challenges
The biggest challenge for this module is error handling, since PowerShell and Internet Explorer are two independent applications that are unaware of each other. HTTP status codes are not exposed to the internet explorer com object and there is no easy way of detecting when you reach an error page on a website (from a broad sence). One solution to get around this is to add more validation step to verify that eveyrthing is running correct and from the expected pages.

## Documentation 
Please see [wiki](https://github.com/heldertyler/PSSynthetics/wiki)
