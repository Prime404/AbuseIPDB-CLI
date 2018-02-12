# AbuseIPDB-CLI for Bash
An attempt to parse and upload data to AbuseIPDB using native bash tools and commands.

## Installation
* Clone the project or download the raw file
* Open the file in an editor of your choice and define the API-key.
* Install any dependecies that this script requires (curl, jq etc)
* Make the file executable using

## Example usage:
```
$ ./abuseipdb.sh -i 127.0.0.1 -c 14 -r "Bruteforce attack against server"
The report has been submitted successfully. The following data was submitted to the abuse database:
IP: 127.0.0.1
Category:Port Scan
Comment:Bruteforce attack against server
```

## To-be-added
* More error checking and clean up of the code
* Verbose mode
