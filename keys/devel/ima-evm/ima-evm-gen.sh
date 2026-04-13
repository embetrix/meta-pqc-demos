
# CA config
cat > ca.cnf <<'EOF'
[dn]
CN = IMA EVM CA
[v3_ca]
basicConstraints = critical, CA:TRUE
keyUsage = critical, keyCertSign
subjectKeyIdentifier = hash
EOF

# Leaf certs/keys
cat > leaf.cnf <<'EOF'
[req]
distinguished_name = dn
req_extensions = v3_leaf
prompt = no
[dn]
CN = IMA EVM Signer
[v3_leaf]
basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature
subjectKeyIdentifier = hash
EOF

for alg in mldsa44 mldsa65 mldsa87; do
    # CA
    openssl genpkey -algorithm $alg -out ima-evm-${alg}-ca.key
    openssl req -x509 -new -nodes -key ima-evm-${alg}-ca.key \
        -subj "/CN=IMA EVM CA ${alg}/" \
        -config ca.cnf -extensions v3_ca \
        -days 3650 -out ima-evm-${alg}-ca.crt

    # Leaf
    openssl genpkey -algorithm $alg -out ima-evm-${alg}.key
    openssl req -new -key ima-evm-${alg}.key \
        -subj "/CN=IMA EVM Signer ${alg}/" \
        -config leaf.cnf -out ima-evm-${alg}.csr
    openssl x509 -req -in ima-evm-${alg}.csr \
        -CA ima-evm-${alg}-ca.crt -CAkey ima-evm-${alg}-ca.key \
        -CAcreateserial \
        -extfile leaf.cnf -extensions v3_leaf \
        -days 3650 -out ima-evm-${alg}.crt
    openssl x509 -in ima-evm-${alg}.crt -outform DER -out ima-evm-${alg}.der
done
