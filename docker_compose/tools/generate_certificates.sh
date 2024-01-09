#!/bin/sh

set -e
set -u

# https://www.openssl.org/docs/manmaster/man1/openssl-verification-options.html
# https://www.openssl.org/docs/manmaster/man5/config.html
# https://git.openssl.org/?p=openssl.git;a=blob;f=apps/openssl.cnf;hb=HEAD

G_CERTIFICATES_DIR=~/Documents/certificates
G_DEVOPS_DOMAIN_NAME=example.com
G_GITLAB_SUBDOMAIN_NAME=gitlab

G_SUBJ_C='FR'
G_SUBJ_ST='Ile-de-France'
G_SUBJ_L=''
G_SUBJ_O='Self-hosted DevOps Ecosystem'
G_SUBJ_OU=''
G_SUBJ_CN_CA='My Root Certificate Authority'
G_SUBJ_CN_SERVER='My self-hosted DevOps Project'
G_SUBJ_EMAILADDRESS=''

create_passphrase () {
	if [ ! -f 'passphrase' ]
	then
		pwgen 20 1 -s > 'passphrase'
		chmod 0600 'passphrase'
	fi
}

create_certificate_authority () {
	if [ ! -f 'ca.crt' ]
	then
		cat 'passphrase'

		openssl genrsa -des3 -out 'ca.key' 1024
		openssl req -new -key 'ca.key' -out 'ca.csr' \
			-subj "/C=${G_SUBJ_C}/ST=${G_SUBJ_ST}/L=${G_SUBJ_L}/O=${G_SUBJ_O}/OU=${G_SUBJ_OU}/CN=${G_SUBJ_CN_CA}/emailAddress=${G_SUBJ_EMAILADDRESS}" \
			-addext 'basicConstraints = critical, CA:true' \
			-addext 'keyUsage = cRLSign, keyCertSign'
		openssl x509 -req -in 'ca.csr' -signkey 'ca.key' -out 'ca.crt' \
			-copy_extensions copy

		openssl x509 -in 'ca.crt' -noout -text
		openssl verify -x509_strict -CAfile 'ca.crt' 'ca.crt'
	fi
}

create_server_certificate () {
	if [ ! -f 'server.crt' ]
	then
		cat 'passphrase'

		openssl genrsa -des3 -out 'server.key' 1024
		openssl req -new -key 'server.key' -out 'server.csr' \
			-subj "/C=${G_SUBJ_C}/ST=${G_SUBJ_ST}/L=${G_SUBJ_L}/O=${G_SUBJ_O}/OU=${G_SUBJ_OU}/CN=${G_SUBJ_CN_SERVER}/emailAddress=${G_SUBJ_EMAILADDRESS}"
		cp 'server.key' 'server.key.passphrase'
		openssl rsa -in 'server.key.passphrase' -out 'server.key'
		openssl x509 -req -days 365 -in 'server.csr' -CA 'ca.crt' -CAkey 'ca.key' -out 'server.crt'

		openssl x509 -in 'server.crt' -noout -text
		openssl verify -x509_strict -show_chain -CAfile 'ca.crt' 'server.crt'
	fi
}

create_certificate_chain () {
	if [ ! -f 'chain.crt' ]
	then
		cat 'server.crt' 'ca.crt' > 'chain.crt'

		openssl crl2pkcs7 -nocrl -certfile 'chain.crt' | openssl pkcs7 -print_certs -noout
	fi
}

main () {
	mkdir -p "${G_CERTIFICATES_DIR}"
	cd "${G_CERTIFICATES_DIR}"
	create_passphrase
	create_certificate_authority
	create_server_certificate
	create_certificate_chain
}

main "${@}"

