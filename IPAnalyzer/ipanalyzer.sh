#!/bin/bash

# Colors
RED='\e[1;91m'
GREEN='\e[1;92m'
YELLOW='\e[1;93m'
BLUE='\e[1;94m'
CYAN='\e[1;96m'
WHITE='\e[1;97m'
RESET='\e[0m'


updated_packages=0 # update detection flag
DISTRO=""
TOR_SERVICE="tor"

if systemctl list-unit-files | grep -q "tor@default.service"; then
    TOR_SERVICE="tor@default"
fi

#check if the user run as root or with sudo

check_sudo() {

   if [ "$EUID" -ne 0 ];then

        echo -e "${YELLOW} Please Run This Tool As Root Or With sudo${RESET}"

        exit 1

   fi 

 }

#function for exit
 exits() {

sudo systemctl stop "$TOR_SERVICE" && exit 0

  }

# Function to check and install dependencies
check_dependencies() {
  echo -e "${YELLOW}Checking required dependencies...${RESET}"
  dependencies=(tor torsocks curl jq)

  for dep in "${dependencies[@]}"; do
    if ! command -v $dep &> /dev/null; then
      echo -e "${RED}[*] $dep not found! Installing...${RESET}"
      if command -v apt &> /dev/null; then
          updated_packages=1
          sudo apt update && sudo apt upgrade -y && sudo apt install -y $dep
      elif command -v dnf &> /dev/null; then
            updated_packages=1
            sudo dnf update -y && sudo dnf install -y $dep
      elif command -v yum &> /dev/null; then
            updated_packages=1
            sudo yum update -y && sudo yum install -y $dep
      elif command -v pacman &> /dev/null; then
            updated_packages=1
            DISTRO="arch"
            sudo pacman -Syu --noconfirm $dep
      fi
    else
      echo -e "${GREEN}[*] $dep is already installed.${RESET}"
    fi
  done

  # Ensure Tor service is running
  if ! systemctl is-active --quiet "$TOR_SERVICE"; then
    echo -e "${YELLOW}Starting Tor service...${RESET}"
    sudo systemctl start "$TOR_SERVICE"
  else
    echo -e "${GREEN}[*] Tor service is running.${RESET}"
  fi
}

# Function to change Tor IP
change_tor_ip() {
  printf "\n${CYAN}Changing Tor IP...${RESET}\n"
  printf "${CYAN}Searching for IP Details...${RESET}\n"
  sudo systemctl reload "$TOR_SERVICE"
  sleep 2
}

# Function to make requests through Tor
tor_request() {
  torsocks curl -s "$1"
}

# Function to make requests without Tor (bypass)
direct_request() {
  curl -s "$1"
}

banner() {
  clear
   echo -e "${GREEN}" 

cat << "EOF" 


  _____ _____                    _                    
 |_   _|  __ \ /\               | |                   
   | | | |__) /  \   _ __   __ _| |_   _ _______ _ __ 
   | | |  ___/ /\ \ | '_ \ / _` | | | | |_  / _ \ '__|
  _| |_| |  / ____ \| | | | (_| | | |_| |/ /  __/ |   
 |_____|_| /_/    \_\_| |_|\__,_|_|\__, /___\___|_|   
                                    __/ |             
                                   |___/              

                                 Developer : Sreeraj

EOF
 
  printf "${RESET}${YELLOW}* GitHub: https://github.com/s-r-e-e-r-a-j${RESET}\n"
 
}

menu() {
  printf "\n"
  printf "${RED}  [${WHITE}01${RED}]${YELLOW} My Original IP${RESET}\n"
  printf "${RED}  [${WHITE}02${RED}]${YELLOW} My Tor IP ${RESET}\n"
  printf "${RED}  [${WHITE}03${RED}]${YELLOW} Track an IP${RESET}\n"
  printf "${RED}  [${WHITE}00${RED}]${YELLOW} Exit${RESET}\n"
  printf "\n"
  read -p $'  \e[1;91m[\e[0m\e[1;97m~\e[0m\e[1;91m]\e[0m\e[1;92m Select An Option: \e[0m' option

  case $option in
    1 | 01) my_original_ip ;;
    2 | 02) my_tor_ip ;;
    3 | 03) track_ip ;;
    0 | 00) exits ;;
    *) 
      printf "${RED}[!] Invalid option${RESET}\n"
      sleep 1
      menu
      ;;
  esac
}

my_original_ip() {
  ip_data=$(direct_request "https://ipapi.co/json")
  parse_ip_data "$ip_data" "Your Original IP"
}

my_tor_ip() {
  change_tor_ip
  ip_data=$(tor_request "https://ipapi.co/json")
  parse_ip_data "$ip_data" "Your Tor IP"
}

track_ip() {
  read -p $'\n\e[1;33mEnter an IP Address: \e[0m' user_ip
  change_tor_ip
  ip_data=$(tor_request "https://ipapi.co/$user_ip/json")
  parse_ip_data "$ip_data" "Details for IP $user_ip"
}

check_reboot_required() {
    reboot_needed=0

    current_kernel="$(uname -r)"
    latest_kernel="$(ls /lib/modules 2>/dev/null | sort -V | tail -n1)"

    # Debian-based reboot flag
    [ -f /var/run/reboot-required ] && reboot_needed=1

    # Kernel mismatch detection
    if [ -n "$latest_kernel" ] && [ "$current_kernel" != "$latest_kernel" ]; then
        reboot_needed=1
    fi

    # RHEL/Fedora reboot detection
    if command -v needs-restarting >/dev/null 2>&1; then
        needs-restarting -r >/dev/null 2>&1
        [ $? -eq 1 ] && reboot_needed=1
    fi

    # Arch Linux: always recommend reboot
    if [ "$DISTRO" = "arch" ] && [ "$updated_packages" -eq 1 ]; then
         reboot_needed=1
    fi

    if [ "$reboot_needed" -eq 1 ]; then
        echo -e "\033[93m[!]\033[0m ZeroTrace: Reboot recommended!"
        echo -e "\033[93m[!]\033[0m Recent system upgrades may leave old libraries"
        echo -e "\033[93m[!]\033[0m or networking components loaded in memory."
        echo -e "\033[93m[!]\033[0m Tor routing or firewall rules may not work correctly."
        echo

        read -rp "Reboot now? [y/N]: " answer

        case "$answer" in
            [Yy]|[Yy][Ee][Ss])
                echo -e "\033[92m[+]\033[0m Rebooting..."
                reboot
                ;;
            *)
                echo -e "\033[93m[!]\033[0m Continuing without reboot."
                ;;
        esac
    fi
}

parse_ip_data() {
  local ip_data=$1
  local title=$2

  local_ip=$(echo "$ip_data" | jq -r '.ip')
  city=$(echo "$ip_data" | jq -r '.city')
  region=$(echo "$ip_data" | jq -r '.region')
  country=$(echo "$ip_data" | jq -r '.country_name')
  country_code=$(echo "$ip_data" | jq -r '.country')
  region_code=$(echo "$ip_data" | jq -r '.region_code')
  languages=$(echo "$ip_data" | jq -r '.languages')
  calling_code=$(echo "$ip_data" | jq -r '.country_calling_code')
  timezone=$(echo "$ip_data" | jq -r '.timezone')
  postal=$(echo "$ip_data" | jq -r '.postal')
  asn=$(echo "$ip_data" | jq -r '.asn')
  isp=$(echo "$ip_data" | jq -r '.org')
  lat=$(echo "$ip_data" | jq -r '.latitude')
  lon=$(echo "$ip_data" | jq -r '.longitude')
  currency=$(echo "$ip_data" | jq -r '.currency')

  printf "\n${CYAN}$title:${RESET}\n"
  printf "  ${GREEN}IP Address   : $local_ip${RESET}\n"
  printf "  ${GREEN}City         : $city${RESET}\n"
  printf "  ${GREEN}Region       : $region${RESET}\n"
  printf "  ${GREEN}Country      : $country${RESET}\n"
  printf "  ${GREEN}Country Code : $country_code${RESET}\n"
  printf "  ${GREEN}Region Code  : $region_code${RESET}\n"
  printf "  ${GREEN}Languages    : $languages${RESET}\n"
  printf "  ${GREEN}Calling Code : $calling_code${RESET}\n"
  printf "  ${GREEN}Timezone     : $timezone${RESET}\n"
  printf "  ${GREEN}Postal Code  : $postal${RESET}\n"
  printf "  ${GREEN}ASN          : $asn${RESET}\n"
  printf "  ${GREEN}ISP          : $isp${RESET}\n"
  printf "  ${GREEN}Latitude     : $lat${RESET}\n"
  printf "  ${GREEN}Longitude    : $lon${RESET}\n"
  printf "  ${GREEN}Currency     : $currency${RESET}\n"
  printf "  ${BLUE}Google Maps  : https://maps.google.com/?q=$lat,$lon${RESET}\n"

  printf "\n${YELLOW}Press Enter to return to the main menu...${RESET}\n"
  read -r
  menu
}

# Main
check_sudo
check_dependencies
[ "$updated_packages" -eq 1 ] && check_reboot_required
banner
menu
