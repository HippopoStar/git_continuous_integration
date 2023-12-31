
## Retrieve GitLab Docker image default config files
```
DOCKER_IMAGE_TAG_GITLAB=latest
GITLAB_CONFIGS_DIR=configs
GITLAB_BIND_MOUNTS_DIR=bind_mounts

mkdir "${GITLAB_CONFIGS_DIR}"

{ docker run --rm gitlab/gitlab-ce:${DOCKER_IMAGE_TAG_GITLAB} cat /opt/gitlab/etc/gitlab.rb.template ;} \
	> "${GITLAB_CONFIGS_DIR}/gitlab.rb"

mkdir "${GITLAB_BIND_MOUNTS_DIR}"

{ docker run --rm gitlab/gitlab-ce:${DOCKER_IMAGE_TAG_GITLAB} cat /assets/wrapper ;} \
	> "${GITLAB_BIND_MOUNTS_DIR}/wrapper"
chmod 0755 "${GITLAB_BIND_MOUNTS_DIR}/wrapper"
```

## Print GitLab self-signed SSL certificate
```
DEVOPS_DOMAIN_NAME=example.com
GITLAB_SUBDOMAIN_NAME=gitlab
GITLAB_HOME=/srv/gitlab

openssl x509 -in ${GITLAB_HOME}/config/ssl/${GITLAB_SUBDOMAIN_NAME}.${DEVOPS_DOMAIN_NAME}.crt -noout -text
```

## Get initial root password
[GitLab - Product documentation - Administer - Administer users - Reset user password - Reset the root password](https://docs.gitlab.com/ee/security/reset_user_password.html#reset-the-root-password)  
[GitLab - GitLab.org - omnibus-gitlab - README.md - After installation](https://gitlab.com/gitlab-org/omnibus-gitlab#after-installation)  
[GitLab - GitLab.org - omnibus-gitlab - files/gitlab-config-template/gitlab.rb.template - L713](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template#L713)  
```
DOCKER_COMPOSE_SERVICE_GITLAB_NAME=gitlab

docker exec "${DOCKER_COMPOSE_SERVICE_GITLAB_NAME}" cat /etc/gitlab/initial_root_password
```

