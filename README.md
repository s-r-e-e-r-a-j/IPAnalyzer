## IPAnalyzer
IPAnalyzer is an OSINT ethical hacking tool built for Linux distributions, designed to gather detailed information about IP addresses. This tool provides geolocation, timezone, country code, ASN, and other valuable data related to any given IP address. It also integrates with the Tor network to ensure anonymity and avoid API rate limiting by frequently changing IP addresses during requests.

This tool is made specifically for Debian-based Linux distributions, like Kali Linux, parrot os, ubuntu and has been tested on Kali Linux to ensure smooth operation.

## Features
- **IP Geolocation:** Get detailed information about the location, country code, timezone, languages, and more.
- **ASN (Autonomous System Number) Lookup:** Retrieve the ASN information of the given IP address.
- **Tor Network Integration:** Automatically routes requests through the Tor network to bypass API rate limits and provide anonymity.
- **API Requests:** Continuously fetch information using Tor by changing IP addresses for each request.
- **Interactive Menu:** User-friendly interface to interact with the tool and easily gather IP-related information.
- **Automated Dependency Installation:** Installs required dependencies automatically if they are not already present.
   - **curl:** Used for making HTTP requests to the API for fetching IP information.
   - **jq:** A lightweight and flexible command-line JSON processor.
   - **Tor:** Used for routing requests through the Tor network to maintain anonymity and avoid rate limits.

## Disclaimer 
IPAnalyzer is a legal OSINT tool developed for educational and ethical purposes. It should be used only on IP addresses and networks you own or have explicit permission to analyze. Any unauthorized or illegal use is strictly prohibited. The developer assumes no responsibility for misuse of this tool.

## Installation
To install and run IPAnalyzer, follow these steps:

1. **Clone the repository:**

```bash
git clone https://github.com/s-r-e-e-r-a-j/IPAnalyzer.git
```
2. **Navigate to the IPAnalyzer directory** 
```bash
cd IPAnalyzer
```
3. **Navigate to the IPAnalyzer directory**
 ```bash
 cd IPAnalyzer
```
4. **Run the tool:**

You can now run the IPAnalyzer tool by executing the following command:

```bash
sudo bash ipanalyzer.sh
```
This will start the tool and display the interactive menu.

## Usage
After running the script, you'll be presented with an interactive menu where you can:

- **Analyze an IP:** Enter an IP address and receive detailed information about it, including geolocation, country, timezone, ASN, and more.
- **Check Your Own IP:** View the current IP address (via Tor or your regular IP) and verify if the requests are being routed through Tor.
- **Exit the Tool:** Option to exit the tool at any time.
  
## Example:
```markdown

  _____ _____                    _                    
 |_   _|  __ \ /\               | |                   
   | | | |__) /  \   _ __   __ _| |_   _ _______ _ __ 
   | | |  ___/ /\ \ | '_ \ / _` | | | | |_  / _ \ '__|
  _| |_| |  / ____ \| | | | (_| | | |_| |/ /  __/ |   
 |_____|_| /_/    \_\_| |_|\__,_|_|\__, /___\___|_|   
                                    __/ |             
                                   |___/              

                                 Developer : Sreeraj

* GitHub: https://github.com/s-r-e-e-r-a-j

  [01] My Original IP
  [02] My Tor IP 
  [03] Track an IP
  [00] Exit

  [~] Select An Option:

```

Follow the prompts to analyze any IP or check your own IP.

## How It Works
1. **IP Analysis:** When you select the option to analyze an IP address, the tool fetches geolocation details such as the city, country, region, timezone, languages, and ASN of the given IP.
2. **Tor Integration:** IPAnalyzer automatically connects to the Tor network if it's not already running, ensuring that each request is routed through a new IP address, which helps in avoiding rate limits imposed by the API.
3. **Anonymous Requests:** The tool helps maintain privacy by masking the user's real IP address during the analysis.

## License
This tool is open-source and available under the MIT License.

