## Description

This image is designed for usage in a development environment. It provides a postfix witch
deliver mails only to allowed domains. All the other mails will be redirected to the MailHog
client which is also running within this image.

## Usage / Examples

Start the container with following command and surf http://localhost:8025

```bash
docker run \
    -p 587:587 -p 8025:8025 \
    -h postfix.project.dev \
    -e ALLOWED_RECEIVER_DOMAINS=example.com,project.dev \
    techdivision/development-postfix:latest
```

Send an email e.g. via curl throw the SMTP port 587. Mails witch are sent to `example.com`
will be sent out. Other mails will be catched by MailHog. You can see them on 
http://localhost:8025

```bash
cat << EOF > /tmp/mail-body.txt
From: User Name <test@example.com>
To: Example User <user@example.com>
Subject: A test email

Message body goes here!
EOF

curl smtp://0.0.0.0:587 \
    --mail-from "test@example.com" \
    --mail-rcpt "user@example.com" \
    -T /tmp/mail-body.txt
```

## Configuration

You can configure the allowed receiver domains with the environment variable 
`ALLOWED_RECEIVER_DOMAINS`. Separate multiple domains with comma.

## docker-compose.yml example

```yml
  postfix:
    restart: always
    image: techdivision/development-postfix:latest
    environment:
      ALLOWED_RECEIVER_DOMAINS: example.com,project.dev
    ports:
      - 587:587
      - 8025:8025
    hostname: postfix.project.dev
```