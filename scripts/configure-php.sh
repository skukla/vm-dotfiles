#!/bin/bash
SUPPORTED_VERSIONS=("7.0" "7.1" "7.2" "7.3")
ACTION_CHOICES=("1) List" "2) Install" "3) Remove" "4) Purge All")

function in_array() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function show_choices() {
    for CHOICE in "${ACTION_CHOICES[@]}"; do printf "${CHOICE}\n"; done
    printf "\n"
}

function show_versions() {
    for VERSION in "${SUPPORTED_VERSIONS[@]}"; do printf "${VERSION}\n"; done
    printf "\n"
}

function check_php() {
    if [ ! -d /etc/php ]; then
        printf "\nThere are no versions of PHP on the system.\n\n"
        exit
    else
        printf "\nHere are the versions of PHP currently available on the system:\n\n"
        ls -la /etc/php
    fi
}

function check_version() {
    REQUESTED_VERSION=$1
    ACTION_CHOICE_TEXT=$2
    # Check to make sure we got the input we expected
    in_array "${REQUESTED_VERSION}" "${SUPPORTED_VERSIONS[@]}"
    if [[ $? != 0 ]]; then
        printf "\nThat isn't a supported  version.  Please try again and select one of the following:\n\n"
        show_versions
        exit
    # If removal is selected, check to see if the requested version is already s    installed
    elif [[ ${ACTION_CHOICE} == "install" ]] && [ ! -d /etc/php/${REQUESTED_VERSION} ]; then 
        printf "\nPHP ${REQUESTED_VERSION} is not installed on the system.\n"
        exit
    # Successful choice
    else
        return 0
    fi  
}

clear
printf "\nSo, you wanna configure PHP, eh?...\n"
sleep 1

# Action choice prompt
printf "\nYou lookin' to list, install, or remove PHP?\n\n"
show_choices
read ACTION_CHOICE

# Enforce a proper choice (Must be an integer and between 1 and 3)
if ! [[ ${ACTION_CHOICE} =~ ^[0-9]+$ ]] || [[ ${ACTION_CHOICE} = "" ]] || [ "${ACTION_CHOICE}" -ne 1 -a "${ACTION_CHOICE}" -ne 2 -a "${ACTION_CHOICE}" -gt 3 ]; then
        printf "\nTry again and please choose 1-3\n"
        sleep 1
        bash ~/cli/scripts/configure-php.sh
fi

# Set version choice text
case ${ACTION_CHOICE} in
    1) check_php; exit ;;
    2) ACTION_CHOICE_TEXT="install" ;;
    3) ACTION_CHOICE_TEXT="remove"; check_php ;;
    4) apt-get remove --purge php7; check_php; exit ;;
esac

# Version prompt
printf "\nOkay, which version of PHP would you like to ${ACTION_CHOICE_TEXT}? (Ex: 7.3)\n\n"

read REQUESTED_VERSION

# Install or remove actions
case ${ACTION_CHOICE_TEXT} in
    install)
        # Check to see if requested version is installed
        check_version $REQUESTED_VERSION $ACTION_CHOICE_TEXT
    
        # Install common packages
        printf "\nYou got it! Attempting to ${ACTION_CHOICE_TEXT} PHP ${REQUESTED_VERSION}...\n\n "
        sudo apt update -y && sudo add-apt-repository ppa:ondrej/php -y && sudo apt update -y && sudo apt install -y php${REQUESTED_VERSION} libapache2-mod-php${REQUESTED_VERSION} php${REQUESTED_VERSION}-common php${REQUESTED_VERSION}-gd php${REQUESTED_VERSION}-mysql php${REQUESTED_VERSION}-curl php${REQUESTED_VERSION}-intl php${REQUESTED_VERSION}-xsl php${REQUESTED_VERSION}-mbstring php${REQUESTED_VERSION}-zip php${REQUESTED_VERSION}-bcmath php${REQUESTED_VERSION}-iconv php${REQUESTED_VERSION}-soap php${REQUESTED_VERSION}-fpm
        
        # Only install mcypt for 7.0 or 7.1
        case ${REQUESTED_VERSION} in
            7.0|7.1)
                sudo apt install -y php${REQUESTED_VERSION}-mcrypt
            ;;
        esac
    ;;
    remove)
        # Check to see if requested version is installed
        check_version $REQUESTED_VERSION $ACTION_CHOICE_TEXT

        # We have the requested version
        printf "\nYou got it! Attempting to ${ACTION_CHOICE_TEXT} PHP ${REQUESTED_VERSION}...\n\n "
        sleep 1

        # Process the package removal first
        sudo apt-get purge php${REQUESTED_VERSION}-common -y
    ;;
esac
sleep 1
# Remove unnecessary packages
printf "\nRemoving any unnecessary packages left behind by the process...\n\n"
sudo apt autoremove -y
sleep 1

# Show resultant PHP versions
check_php
sleep 1
printf "\ndone.\n"