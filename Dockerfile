FROM alpine:3

ARG GITLAB_RUNNER_VERSION=v13.1.4
ARG TERRAFORM_VERSION=0.12.31
ARG TINI_VERSION=v0.19.0

RUN apk add --no-cache --virtual builddeps curl unzip && \
    apk add --no-cache git-lfs openssh jq python3 py3-pip && \
    pip install awscli && \
    aws --version && \
    git lfs install --skip-repo && \
    curl -Lo /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64 && \
    chmod +x /usr/local/bin/gitlab-runner && \
    curl -Lo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip && \
    curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/local/bin/tini && \
    apk del builddeps && \
    mkdir -p /var/run/sshd

EXPOSE 22

COPY entrypoint.sh /usr/local/bin/
COPY convert_report /usr/local/bin/
COPY sshd_config /root/sshd_config
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
