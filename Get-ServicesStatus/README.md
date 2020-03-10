# Get-ServicesStatus
VERSION = 1.0.0

List the status of the service or services indicated in the input parameter

## Getting Started

List in a form the status of the service or services indicated in the input parameter. 

The possible states are STARTED, STOPPED and DOES NOT EXIST

### Prerequisites

N/A

### Example

Get the status of a service passed as a parameter (ServiceName):

```
Get-ServicesStatus mfefire
```

Obtain the status of the services contained in a csv:
```
$services = Get-Content .\services.csv
$Services = ($services).split(",")
Get-ServicesStatus $services
```

## Authors

* **Xavi Saavedra** 

## License

[GNU General Public License v3.0](PowerShell/LICENSE)
