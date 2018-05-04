#!/bin/bash
printf "\n"
awk 'BEGIN { format = "%-10s\n"
             printf format, "BACKENDS"
             printf format, "========" }'

printf "\nRemember to replace 'luma.com' with the hostname configured in config.yml.\n"

awk 'BEGIN { format = "\n%-20s %-30s %-30s"
             printf format, "Service", "URL", "Creds"
             printf format, "---------------", "----------------", "---------------"
             printf format, "Magento Admin", "http://luma.com/admin", "admin/admin4tls"
             printf format, "RabbitMQ Admin", "http://luma.com:15672", "guest/guest"
             printf format, "PHP MyAdmin", "http://luma.com/phpmyadmin", "magento/password"
             printf format, "Kibana Admin", "http://luma.com:5601", ""
             }'
printf "\n\n"
