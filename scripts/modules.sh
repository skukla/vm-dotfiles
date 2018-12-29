#!/bin/bash
modulesListArray=(
  'Amasty Base'
  'Amasty Blog'
  'Amasty Duplicate Categories'
  'Amasty Geo-IP'
  'Amasty Group Categories'
  'Amasty Product Attachments'
  'Amasty Promotions'
  'Amasty Special Promotions'
  'Amasty Special Promotions Pro'
  'Amasty Store Locator'
  'Amasty Enhanced Product Grid'
  'M2E Pro'
  'ParadoxLabs Tokenbase'
  'ParadoxLabs Subscriptions'
  'ParadoxLabs First Data Payment Method'
  'ParadoxLabs Authorize.net CIM Payment Method'
  'ParadoxLabs Stripe Payment Method'
);

modulesInstallArray=(
  "amasty/base:dev-master"
  "amasty/blog:dev-master"
  "amasty/duplicatecategories:dev-master"
  "amasty/geoip:dev-master"
  "amasty/groupcat:dev-master"
  "amasty/product-attachment:dev-master"
  "amasty/promo:dev-master"
  "amasty/module-special-promo:dev-master"
  "amasty/module-special-promo-pro:dev-master"
  "amasty/module-store-locator:dev-master"
  "amasty/rgrid:dev-master"
  "m2epro/magento2-extension:dev-master"
  "paradoxlabs/tokenbase"
  "paradoxlabs/subscriptions:dev-master"
  "paradoxlabs/authnetcim:dev-master"
  "paradoxlabs/firstdata:dev-master"
  "paradoxlabs/stripe:dev-master"
);

option=$1

clear
printf "So, you want to ${option} some modules, eh?\n\n"
printf "Cool, here's a list to choose from:\n\n"
sleep 1

# Show module list
for i in "${!modulesListArray[@]}"; do
  printf "%s %s\n" "$i." "${modulesListArray[$i]}"
done

printf "\nEnter the number of the modules you want to ${option} in a space-separated list and then press ENTER  (E.g. 0 3 5) or use 'all':\n\n"

# Get user choice as a string
read choice

# Convert the string into an array
IFS=', ' read -r -a choiceArray <<< "$choice"

# Create an array of modules to install from the choices the user made
for choice in ${choiceArray[@]}
do
  installArray=( "${installArray[@]}" "${modulesInstallArray[$choice]}" )
done

# Handle uninstalling modules first because it's shorter
if [[ $option = "uninstall" ]]; then
  # Strip module versions from installArray for composer remove statement
  for module in ${installArray[@]}
  do
    uninstallArray=( "${module%:*}" "${uninstallArray[@]}" )
  done
  # Process all modules for uninstall
  if [[ $choice = "all" ]]; then
    for module in ${modulesInstallArray[@]}
    do
      uninstallArray=( "${module%:*}" "${uninstallArray[@]}" )
    done
  fi
  printf "\nUninstalling the following modules:\n"
# Now handle installation
else
  # Search the array of modules to install for Amasty or ParadoxLabs and add them
  for module in ${installArray[@]}
  do
    if [[ $module = *"amasty"* ]]; then
      installArray=( "${modulesInstallArray[0]}" "${installArray[@]}" )
    fi
    if [[ $module = *"paradoxlabs"* ]]; then
      installArray=( "${modulesInstallArray[12]}" "${installArray[@]}" )
    fi
    if [[ $module = *"pro"* ]]; then
      installArray=( "${modulesInstallArray[7]}" "${installArray[@]}" )
    fi
  done
  # Show choices to confirm
  printf "\nInstalling the following modules:\n"
fi

# Show module list and add key for both install and uninstall
if [[ "$choice" = "all" ]]; then
  for module in ${modulesInstallArray[@]}
  do
    printf "$module\n"
  done
  printf "\n"
else
  for module in ${installArray[@]}
  do
    printf "$module\n"
  done
  printf "\n"
fi

sleep 2

add-key
printf "\n"

# Use composer to require or remove the chosen modules
www
if [[ "$option" = "install" ]]; then
  if [[ "$choice" = "all" ]]; then
    composer require "${modulesInstallArray[@]}"
  else
    composer require "${installArray[@]}"
  fi
else
  composer remove "${uninstallArray[@]}"
fi
add-modules