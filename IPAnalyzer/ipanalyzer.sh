#!/bin/bash

# Colors
RED='\e[1;91m'
GREEN='\e[1;92m'
YELLOW='\e[1;93m'
BLUE='\e[1;94m'
CYAN='\e[1;96m'
WHITE='\e[1;97m'
RESET='\e[0m'


#check if the user run as root or with sudo

check_sudo() {

   if [ "$EUID" -ne 0 ];then

        echo -e "${YELLOW} Please Run This Tool As Root Or With sudo${RESET}"

        exit 1

   fi 

 }

# Function to check and install dependencies
check_dependencies() {
  echo -e "${YELLOW}Checking required dependencies...${RESET}"
  dependencies=(tor torsocks curl jq)

  for dep in "${dependencies[@]}"; do
    if ! command -v $dep &> /dev/null; then
      echo -e "${RED}[*] $dep not found! Installing...${RESET}"
      sudo apt update && sudo apt install -y $dep
    else
      echo -e "${GREEN}[âœ”] $dep is already installed.${RESET}"
    fi
  done

  # Ensure Tor service is running
  if ! systemctl is-active --quiet tor; then
    echo -e "${YELLOW}Starting Tor service...${RESET}"
    sudo service tor start
  else
    echo -e "${GREEN}[âœ”] Tor service is running.${RESET}"
  fi
}

# Function to change Tor IP
change_tor_ip() {
  printf "\n${CYAN}Changing Tor IP...${RESET}\n"
  echo -e 'AUTHENTICATE ""\r\nsignal NEWNYM\r\nquit' | nc localhost 9051 > /dev/null
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
 
  printf "${RESET}${YELLOW}* Copyright Â© Sreeraj, 2024${RESET}\n"
  printf "${YELLOW}* GitHub: https://github.com/s-r-e-e-r-a-j${RESET}\n"
 
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
    0 | 00) exit 0 ;;
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
  parse_ip_data "$ip_data" "Your Tor Exit Node IP"
}

track_ip() {
  read -p $'\n\e[1;33mEnter an IP Address: \e[0m' user_ip
  change_tor_ip
  ip_data=$(tor_request "https://ipapi.co/$user_ip/json")
  parse_ip_data "$ip_data" "Details for IP $user_ip"
}

parse_ip_data() {
  local ip_data=$1
  local title=$2

  local_ip=$(echo $ip_data | jq -r '.ip')
  city=$(echo $ip_data | jq -r '.city')
  region=$(echo $ip_data | jq -r '.region')
  country=$(echo $ip_data | jq -r '.country_name')
  country_code=$(echo $ip_data | jq -r '.country')
  languages=$(echo $ip_data | jq -r '.languages')
  calling_code=$(echo $ip_data | jq -r '.country_calling_code')
  timezone=$(echo $ip_data | jq -r '.timezone')
  postal=$(echo $ip_data | jq -r '.postal')
  asn=$(echo $ip_data | jq -r '.asn')
  isp=$(echo $ip_data | jq -r '.org')
  lat=$(echo $ip_data | jq -r '.latitude')
  lon=$(echo $ip_data | jq -r '.longitude')
  currency=$(echo $ip_data | jq -r '.currency')

  printf "\n${CYAN}$title:${RESET}\n"
  printf "  ${GREEN}IP Address   : $local_ip${RESET}\n"
  printf "  ${GREEN}City         : $city${RESET}\n"
  printf "  ${GREEN}Region       : $region${RESET}\n"
  printf "  ${GREEN}Country      : $country${RESET}\n"
  printf "  ${GREEN}Country Code : $country_code${RESET}\n"
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
banner
menu
