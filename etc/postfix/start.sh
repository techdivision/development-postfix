#!/bin/bash

# Disable SMTPUTF8, because libraries (ICU) are missing in alpine
postconf -e smtputf8_enable=no

# Update aliases database. It's not used, but postfix complains if the .db file is missing
postalias /etc/postfix/aliases

# Disable local mail delivery
postconf -e mydestination=
# Don't relay for any domains
postconf -e relay_domains=

# Reject invalid HELOs
postconf -e smtpd_delay_reject=yes
postconf -e smtpd_helo_required=yes
postconf -e "smtpd_helo_restrictions=permit_mynetworks,reject_invalid_helo_hostname,permit"

# Set up my networks to list only networks in the local loopback range
postconf -e "mynetworks=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

# Set SMTPd restrictions
postconf -# "smtpd_restriction_classes"
postconf -e "smtpd_recipient_restrictions=reject_non_fqdn_recipient,reject_unknown_recipient_domain,reject_unverified_recipient"

# Add transport map configuration
echo "Setting up allowed RECEIVER domains:"
FILE=/etc/postfix/transport
rm -f $FILE $FILE.db > /dev/null
touch $FILE
if [[ ! -z "$ALLOWED_RECEIVER_DOMAINS" ]]; then
    for domain in $(echo $ALLOWED_RECEIVER_DOMAINS | sed "s/,/ /g"); do
        echo -e "$domain\t\t\t:" >> $FILE
    done
fi
echo -e "*\t\t\tsmtp:0.0.0.0:1025" >> $FILE
postmap $FILE
postconf -e "transport_maps = hash:$FILE"

# Use 587 (submission)
sed -i -r -e 's/^#submission/submission/' /etc/postfix/master.cf

/usr/sbin/postfix -c /etc/postfix start