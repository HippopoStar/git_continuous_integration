#!/bin/sh

envsubst \
	'${GITLAB_SUBDOMAIN_NAME}:${DEVOPS_DOMAIN_NAME}' \
	< /tmp/default.conf \
	> /etc/nginx/conf.d/default.conf

