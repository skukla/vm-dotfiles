#!/bin/bash
SUPPORTED_VERSIONS=("7.0" "7.1" "7.2" "7.3")
ACTION_CHOICES=("1) List currently installed versions" "2) Install a version" "3) Remove a version" "4) Purge all versions")

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
}

function check_php() {
    if [ ! -d /etc/php ]; then
        printf "\nThere are no versions of PHP on the system.\n\n"
        return 1
    else
        printf "\nHere are the versions of PHP currently available on the system:\n\n"
        sleep 1
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
    # If removal is selected, check to see if the requested version is already installed
    elif [[ ${ACTION_CHOICE} == "remove" ]] && [ ! -d /etc/php/${REQUESTED_VERSION} ]; then 
        printf "\nPHP ${REQUESTED_VERSION} is not installed on the system.\n"
        exit
    # Successful choice
    else
        return 0
    fi  
}

function install_or_remove() {
    case ${ACTION_CHOICE_TEXT} in
        install)
            # Check to see if requested version is installed
            check_version $REQUESTED_VERSION $ACTION_CHOICE_TEXT
            # Install common packages
            printf "\nYou got it! Attempting to ${ACTION_CHOICE_TEXT} PHP ${REQUESTED_VERSION}...\n\n"
            sleep 1
            sudo apt update -y && sudo add-apt-repository ppa:ondrej/php -y && sudo apt update -y && sudo apt install -y php${REQUESTED_VERSION} libapache2-mod-php${REQUESTED_VERSION} php${REQUESTED_VERSION}-common php${REQUESTED_VERSION}-gd php${REQUESTED_VERSION}-mysql php${REQUESTED_VERSION}-curl php${REQUESTED_VERSION}-intl php${REQUESTED_VERSION}-xsl php${REQUESTED_VERSION}-mbstring php${REQUESTED_VERSION}-zip php${REQUESTED_VERSION}-bcmath php${REQUESTED_VERSION}-iconv php${REQUESTED_VERSION}-soap php${REQUESTED_VERSION}-fpm
            # Only install mcypt for 7.0 or 7.1
            case ${REQUESTED_VERSION} in
                7.0|7.1)
                    sudo apt install -y php${REQUESTED_VERSION}-mcrypt
                ;;
            esac
            # Update FPM
            printf "\nUpdating the FPM www.conf file..."
            sudo sed -i -e 's/user = www-data/user = vagrant/' -e '0,/group =/{s/group = www-data/group = vagrant/}' -e 's/^listen = \/run\/php/c\listen = 127.0.0.1:9000;' /etc/php/${REQUESTED_VERSION}/fpm/pool.d/www.conf
            sleep 1
            printf "done.\n"
            # Update PHP ini files (CLI and FPM)
            printf "\nUpdating the FPM and CLI ini files..."
            sudo sed -i -e 's/;date.timezone =/date.timezone = America\/Los_Angeles/' -e 's/max_execution_time = 30/max_execution_time = 1800/' -e 's/memory_limit = -1/memory_limit = 2G/' -e 's/zlib.output_compression = Off/zlib.output_compression = On/' /etc/php/${REQUESTED_VERSION}/cli/php.ini
            sudo sed -i -e 's/;date.timezone =/date.timezone = America\/Los_Angeles/' -e 's/max_execution_time = 30/max_execution_time = 1800/' -e 's/memory_limit = 128M/memory_limit = 2G/' -e 's/zlib.output_compression = Off/zlib.output_compression = On/' /etc/php/${REQUESTED_VERSION}/fpm/php.ini
            sleep 1
            printf "done.\n"
            # Restart FPM
            printf "\nRestarting PHP-FPM ${REQUESTED_VERSION}...\n"
            sudo systemctl restart php${REQUESTED_VERSION}-fpm
            sleep 1
            printf "done.\n"
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
}

function set_action_choice() {
    # Set version choice text
    case ${ACTION_CHOICE} in
        1) 
            check_php
            exit ;;
        2) 
            ACTION_CHOICE_TEXT="install"
            printf "\nPlease choose between these versions:\n\n"
            show_versions
            check_php ;;
        3) 
            ACTION_CHOICE_TEXT="remove"
            check_php
            printf "\n";;
        4) 
            printf "\nYou got it! Attempting to purge all versions of PHP 7...\n "
            sleep 1
            check_php; if [ "$?" = 1 ]; then exit; fi; 
            printf "\n"
            sleep 1
            sudo apt-get remove --purge php7.* -y
            sudo apt autoremove -y
            check_php
            exit ;;
    esac
}

clear

# Action choice prompt
printf "\nSo, you wanna configure PHP, eh?...\n\n"
sleep 1
show_choices
read ACTION_CHOICE

# Enforce a proper choice (Must be an integer and between 1 and 4)
if ! [[ ${ACTION_CHOICE} =~ ^[0-9]+$ ]] || [[ ${ACTION_CHOICE} = "" ]] || [ "${ACTION_CHOICE}" -ne 1 -a "${ACTION_CHOICE}" -ne 2 -a "${ACTION_CHOICE}" -ne 3 -a "${ACTION_CHOICE}" -gt 4 ]; then
        printf "\nTry again and please choose 1-4\n"
        exit
fi
set_action_choice
sleep 1

# Version prompt
printf "Okay, which version of PHP would you like to ${ACTION_CHOICE_TEXT}? (Ex: 7.3)\n\n"
read REQUESTED_VERSION
install_or_remove
sleep 1
printf "\ndone.\n"
exit 0