#!/bin/bash
SUPPORTED_VERSIONS=("7.0" "7.1" "7.2" "7.3")

function in_array() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function show_versions() {
    for v in "${SUPPORTED_VERSIONS[@]}"; do printf "${v}\n"; done
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
    ACTION_CHOICE=$2
    # Check to make sure we got the input we expected
    in_array "${REQUESTED_VERSION}" "${SUPPORTED_VERSIONS[@]}"
    if [[ $? != 0 ]]; then
        printf "\nThat isn't a supported  version.  Please try again and select one of the following:\n\n"
        show_versions
        exit
    # If removal is selected, check to see if the requested version is already s    installed
    elif [[ ${ACTION_CHOICE} == 2 ]] && [ ! -d /etc/php/${REQUESTED_VERSION} ]; then 
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
printf "\nYou lookin' to list, install, or remove PHP?\n\n1) List\n2) Remove\n3) Install\n\n"
read ACTION_CHOICE

# Enforce a proper choice
if [[ ${ACTION_CHOICE} = "" ]] || [[ ${ACTION_CHOICE} >= 1 ]] && [[ ${ACTION_CHOICE} <= 3 ]]; then
    printf "\nTry again and please choose 1-3\n"
    exit
fi

# Set version choice text
case ${ACTION_CHOICE} in
    1) ACTION_CHOICE_TEXT="install" ;;
    2) 
        ACTION_CHOICE_TEXT="remove"
        # Check to see if any version of PHP is installed
        check_php
        ;;
    3) check_php ;;
esac

# Version prompt
printf "\nOkay, which version of PHP would you like to ${ACTION_CHOICE_TEXT}? (Ex: 7.3)\n\n"

read REQUESTED_VERSION

# Install or remove actions
case ${ACTION_CHOICE} in
    # Install
    1)
        # Check to see if requested version is installed
        check_version $REQUESTED_VERSION $ACTION_CHOICE
    
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
    # Remove
    2)
        # Check to see if requested version is installed
        check_version $REQUESTED_VERSION $ACTION_CHOICE

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