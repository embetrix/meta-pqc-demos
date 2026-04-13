# Kernel Module MLDSA Keys/Cert generation

## Generate mldsa44 private key

```
openssl genpkey -algorithm mldsa44 -out modsign-mldsa44.key
```

## Create a self-signed certificate (valid for 10 years)

```
openssl req -x509 -new -nodes  \
    -key modsign-mldsa44.key \
    -subj "/CN=Kernel Module Self-Signed mldsa44/" \
    -days 3650 -out modsign-mldsa44.crt
```

## Generate mldsa65 private key

```
openssl genpkey -algorithm mldsa65 -out modsign-mldsa65.key
```

## Create a self-signed certificate (valid for 10 years)

```
openssl req -x509 -new -nodes  \
    -key modsign-mldsa65.key \
    -subj "/CN=Kernel Module Self-Signed mldsa65/" \
    -days 3650 -out modsign-mldsa65.crt
```

## Generate mldsa87 private key

```
openssl genpkey -algorithm mldsa87 -out modsign-mldsa87.key
```

## Create a self-signed certificate (valid for 10 years)

```
openssl req -x509 -new -nodes  \
    -key modsign-mldsa87.key \
    -subj "/CN=Kernel Module Self-Signed mldsa87/" \
    -days 3650 -out modsign-mldsa87.crt
```
