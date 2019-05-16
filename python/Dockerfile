FROM python:3.7.2-alpine3.9
WORKDIR /terraform
ENV TERRAFORM_VERSION 0.11.13

RUN apk --update --no-cache add curl && cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

COPY requirements.txt .
RUN pip3 install -r requirements.txt && mkdir -p /root/.aws && touch /root/.aws/credentials
ENTRYPOINT ["/bin/ash"]