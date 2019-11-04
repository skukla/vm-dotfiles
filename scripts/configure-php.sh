#!/bin/bash
SUPPORTED_VERSIONS=("7.0" "7.1" "7.2" "7.3")

function inArray() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function show_versions() {
    printf "\nPlease select a supported PHP version. Supported versions are:"
    for v in "${SUPPORTED_VERSIONS[@]}"; do printf "${v}\n"; done
}

function php_check() {
    # If they want to remove a version, check to see if there are any versions at all
    if [[ ! $(ls -A /etc/php) ]]; then
        printf "\nThere are no versions of PHP on the system.\n\n"
        return 1
    fi
}

function match_version() {
    REQUESTED_VERSION=$1
    # Check to make sure we got the input we expected...
    for MENU_ITEM in "${SUPPORTED_VERSIONS[@]}";
    do 
        if [[ ${REQUESTED_  VERSION} != ${MENU_ITEM} ]]; then
            show_versions
        fi
    done
    if  [ ! -d /etc/php/${VERSION} ]; then
        printf "\nThere are no occurrences of PHP ${VERSION} on the system.\n"
        return
    fi
}

function list_php() {
  printf "\nHere are the versions of PHP currently available on the system:\n\n"
  ls -la /etc/php
}

### START ###
clear
if [[ ! $(inArray "7.0" "${SUPPORTED_VERSIONS[@]}") ]]; then
    printf "No match"
else
    printf "Match"
fi

# printf "\nSo, you wanna configure PHP, eh?...\n"
# sleep 1

# printf "You lookin' to install or remove PHP?\n\n1) Install\n2) Remove\n\n"
# read CHOICE

# sleep 1

# # Which version?
# printf "\nOkay, which version of PHP would you like to ${CHOICE_TEXT}? (Ex: 7.3)\n\n"
# read VERSION

# # Install or remove?
# case ${CHOICE} in
#     1)
#         CHOICE_TEXT="install"
#     ;;
#     2)
#         CHOICE_TEXT="remove"
#         # Check to see whether the request PHP version exists...
#     ;;
#     1|2)
#         printf "\nOkay, which version of PHP would you like to ${CHOICE_TEXT}? (Ex: 7.3)\n\n"
#     ;;
# esac


# # We have something installed, so show a list...
# list_php

# # Version match
# match_version

# # Check to see whether the request PHP version exists...
# if [[ {$CHOICE} == 2 ]] && [ ! -d /etc/php/${VERSION} ]; then
# printf "\nThere are no occurrences of PHP ${VERSION} on the system.\n"
# return
# fi

# # We have the requested version
# printf "\nYou got it!  Attempting to ${CHOICE_TEXT} PHP ${VERSION}...\n\n "
# sleep 1
# case ${CHOICE} in
# 1)
#     sudo apt update -y && sudo add-apt-repository ppa:ondrej/php -y && sudo apt update -y && sudo apt install -y php${VERSION} libapache2-mod-php${VERSION} php${VERSION}-common php${VERSION}-gd php${VERSION}-mysql php${VERSION}-curl php${VERSION}-intl php${VERSION}-xsl php${VERSION}-mbstring php${VERSION}-zip php${VERSION}-bcmath php${VERSION}-iconv php${VERSION}-soap php${VERSION}-fpm
#     # Only install mcypt for 7.0 or 7.1
#     case ${VERSION} in
#     7.0|7.1)
#         sudo apt install -y php${VERSION}-mcrypt
#     ;;
#     esac
#     ;;
# 2)
#     # Process the package removal first
#     sudo apt-get install ppa-purge -y && sudo apt-get purge php${VERSION}-common
    
#     # Check for 7.0 specifically and remove its folder
#     if [[ ${VERSION} == 7.0 ]]; then
#     printf "\nRemoving /etc/php/ folder contents...\n"
#     sudo apt-get remove -y --purge php7.0*
#     sudo rm -rf /etc/php/7.0/ 
#     fi
#     ;;
# esac
# printf "\nRemoving any unnecessary packages left behind by the PHP installation...\n"
# sudo apt autoremove -y
# sleep 1
# list-php
# sleep 1
# printf "\ndone.\n"
