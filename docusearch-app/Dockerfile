FROM node as builder

WORKDIR /docusearch-app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine3.17
WORKDIR /docusearch-cert

RUN apk add openssl

RUN openssl req -x509 -newkey rsa:4096 -keyout docusearch-key.pem -out docusearch-cert.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"

COPY --from=builder /docusearch-app/dist /www/docusearch
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
