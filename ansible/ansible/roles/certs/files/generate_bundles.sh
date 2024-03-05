#!/usr/bin/env bash
# Wirepas Ltd

CERT_DIR=${CERT_DIR:-"haproxy_certs"}

CN_NAME=${CN_NAME:-"mydomain.com"}
SERVER_DNS=${SERVER_DNS:-"example.mydomain.com"}

KEY_LENGHT=${KEY_LENGHT:-"4096"}

ORGANIZATION_NAME=${ORGANIZATION_NAME:-"my_organization"}
ORGANIZATION_UNIT=${ORGANIZATION_UNIT:-"my_org_unit"}
COUNTRY_CODE=${COUNTRY_CODE:-"FI"}
VALID_DAYS=${VALID_DAYS:-365}
SIGNATURE_ALGORITHM=${SIGNATURE_ALGORITHM:-"-sha256"}

# create cert folder ${CERT_DIR}
mkdir -p "${CERT_DIR}" || true

# generate rootca key
openssl genrsa -out "${CERT_DIR}/rootca_${CN_NAME}.key" "${KEY_LENGHT}"

# generate server certificate signing request
openssl req -new \
            -subj "/C=${COUNTRY_CODE}/O=${ORGANIZATION_NAME}/OU=${ORGANIZATION_UNIT}/CN=${SERVER_DNS}" \
            -key "${CERT_DIR}/rootca_${CN_NAME}.key" \
            -out "${CERT_DIR}/server_${CN_NAME}.csr"

# generate server key
openssl genrsa -out "${CERT_DIR}/ca_${CN_NAME}.key" "${KEY_LENGHT}"

# generate self signed certificate for CA
openssl req -days "${VALID_DAYS}" -new \
            -x509 \
            -subj "/C=${COUNTRY_CODE}/O=${ORGANIZATION_NAME}/OU=${ORGANIZATION_UNIT}§/CN=${SERVER_DNS}" \
            -key "${CERT_DIR}/ca_${CN_NAME}.key" \
            -out "${CERT_DIR}/ca_${CN_NAME}.crt"

# sign self signed certificate
openssl x509 -days "${VALID_DAYS}" -req "${SIGNATURE_ALGORITHM}" \
             -in "${CERT_DIR}/server_${CN_NAME}.csr" \
             -CA "${CERT_DIR}/ca_${CN_NAME}.crt" \
             -CAkey "${CERT_DIR}/ca_${CN_NAME}.key" \
             -CAcreateserial \
             -out "${CERT_DIR}/${CN_NAME}.crt"

# generate wnt keychain server bundle.pem
cat "${CERT_DIR}/ca_${CN_NAME}.crt" \
    "${CERT_DIR}/${CN_NAME}.crt" \
    "${CERT_DIR}/ca_${CN_NAME}.key" > "${CERT_DIR}/bundle.pem"

# generate wnt gateway gateway_bundle.pem
cat "${CERT_DIR}/ca_${CN_NAME}.crt" \
    "${CERT_DIR}/${CN_NAME}.crt" > "${CERT_DIR}/gateway_bundle.pem"