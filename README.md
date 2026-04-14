# meta-pqc-demos

Yocto/Openembedded layer dedicated to Post-Quantum Cryptography and end-to-end demos,
built on top of `poky-bleeding` and the `linux-7.x` kernel series.
It integrates PQC across the `linux kernel`, `OpenSSL` and `OpenSSH`
primarily around ML-DSA and ML-KEM.

## What this demonstrates

### linux v7.x kernel PQC support 
- Kernel module signature verification with PQC signatures via the new:
  `CONFIG_MODULE_SIG_KEY_TYPE_MLDSA_{44,65,87}` options.
- `CONFIG_MODULE_SIG_ENFORCE=y` unsigned or invalidly signed modules are rejected at load time.
- In-kernel ML-DSA asymmetric key support via `CONFIG_CRYPTO_MLDSA` with X.509 and PKCS#7 parsers.
- Scaffolding for IMA/EVM with ML-DSA (currently not working yet).

### Userspace PQC support
- `OpenSSL` ships with native ML-KEM / ML-DSA / SLH-DSA support, no
  external provider required. All applications linked against `libssl` and `libcrypto` in the image inherit PQC support automatically.
- `OpenSSH`  with hybrid PQC key exchange supports `mlkem768x25519-sha256`/`sntrup761x25519-sha512` hybrid KEX.
- `curl/libcurl`  TLS 1.3 over OpenSSL, negotiates the hybrid `X25519MLKEM768` group out of the box.
- `leancrypto` embedded-friendly PQC library included in the image for application-level experimentation.

More PQC demos are on the way including:

- IMA/EVM file integrity with ML-DSA once the kernel verifier support it correctly
- Hybrid PQC X.509 CA + TLS server/client walkthrough (nginx + curl)
- MQTT (mosquitto) over hybrid PQC TLS end-to-end demo
- Swupdate bundles signed with ML-DSA
- PQC-enabled VPN (OpenVPN)

## Build

```
KAS_MACHINE=qemux86-64 kas build kas-pqc-demos.yml
```

## Run with QEMU

```
KAS_MACHINE=qemux86-64 kas shell kas-pqc-demos.yml \
                       -c 'runqemu kvm serialstdio nographic snapshot \
                       qemuparams="-m 1024" \
                       bootparams="ima_policy=tcb ima_appraise=enforce evm=off"'
```

## Verifying on the target

### Kernel module signing (ML-DSA)

```
# Confirm enforcement is on
cat /sys/module/module/parameters/sig_enforce
Y
```

```
# Inspect the ML-DSA signature appended to a signed module
root@qemux86-64:~# modinfo tun| grep -E 'sig_|signer'
sig_id:         PKCS#7
signer:         Kernel Module Self-Signed mldsa65
sig_key:        4C:44:A1:6E:B2:1A:37:C2:C6:9E:A8:08:FB:15:5F:E4:63:4C:AD:1A
sig_hashalgo:   sha512
```

```
root@qemux86-64:~# modinfo tun
filename:       /lib/modules/7.0.0-rc7-yoctodev-standard/kernel/drivers/net/tun.ko
import_ns:      NETDEV_INTERNAL
alias:          devname:net/tun
alias:          char-major-10-200
license:        GPL
author:         (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
description:    Universal TUN/TAP device driver
depends:
intree:         Y
name:           tun
retpoline:      Y
vermagic:       7.0.0-rc7-yoctodev-standard SMP preempt mod_unload
sig_id:         PKCS#7
signer:         Kernel Module Self-Signed mldsa65
sig_key:        4C:44:A1:6E:B2:1A:37:C2:C6:9E:A8:08:FB:15:5F:E4:63:4C:AD:1A
sig_hashalgo:   sha512
signature:      55:05:53:EB:AA:30:3D:39:76:74:4B:DF:16:A9:B9:EB:7C:DA:8A:55:
                F2:E5:92:B5:DB:97:3C:56:A9:8F:0F:C0:A6:DE:6B:F7:54:55:87:3C:
                96:09:97:46:85:19:3A:20:2C:E0:C7:8C:F2:F4:DE:E5:15:13:32:1D:
                0A:F0:DE:4A:15:0E:37:94:13:AA:24:C0:2B:F7:A8:00:A8:84:D2:DF:
                A1:F5:E3:14:CF:A9:95:3E:2B:D7:F4:24:29:F6:1A:12:AE:E4:7F:4D:
                08:85:C5:7A:FD:B1:71:4C:67:46:68:01:8A:D0:6E:46:CC:5D:52:DB:
                FC:26:5B:C2:B6:AB:71:B3:0E:A2:6C:A1:78:41:BA:DB:22:29:72:1E:
                91:E1:28:73:38:16:5B:F0:39:DD:10:BD:FE:C6:05:72:07:5A:DD:5C:
                ...
```

### IMA/EVM

The image boots with the built-in `tcb` measurement policy attached via the
`ima_policy=tcb` kernel cmdline (see the `runqemu` invocation above).
Appraisal with ML-DSA signatures is still WIP pending the in-kernel verifier.

Inspect IMA/EVM xattrs on a file:

```
getfattr -m - -d /bin/ls   # security.ima / security.evm
```

Kernel-side integrity messages:

```
dmesg | grep -Ei 'ima|evm|integrity'
```

### OpenSSL with PQC
```
openssl list -signature-algorithms | grep -Ei 'ml-dsa|slh-dsa'
openssl list -kem-algorithms       | grep -i  'ml-kem'
```

Example `curl` TLS1.3 handshake to `https://google.com` from the target 
the group used is the hybrid `X25519MLKEM768` demonstrating end-to-end
PQC-protected TLS against a real public server :


<pre>
root@qemux86-64:~# curl -v https://google.com
* Host google.com:443 was resolved.
*   Trying 216.58.198.206:443...
* ALPN: curl offers http/1.1
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
*   CAfile: /etc/ssl/certs/ca-certificates.crt
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
<mark>* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / X25519MLKEM768 / id-ecPublicKey</mark>
* ALPN: server accepted http/1.1
* Server certificate:
*   subject: CN=*.google.com
*   issuer: C=US; O=Google Trust Services; CN=WR2
* SSL certificate verified via OpenSSL.
> GET / HTTP/1.1
> Host: google.com
> User-Agent: curl/8.19.0
< HTTP/1.1 301 Moved Permanently
< Location: https://www.google.com/
</pre>


### OpenSSH hybrid PQC KEX
```
ssh -Q kex | grep -Ei 'mlkem|sntrup'
ssh -o KexAlgorithms=mlkem768x25519-sha256 user@host
```

Example `ssh -v` session on the target  OpenSSH 10.2 / OpenSSL 3.5.6
negotiating the hybrid `mlkem768x25519-sha256` KEX:


<pre>
root@qemux86-64:~# ssh localhost -v
debug1: OpenSSH_10.2p1, OpenSSL 3.5.6 7 Apr 2026
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: Connecting to localhost [::1] port 22.
debug1: Connection established.
debug1: Local version string SSH-2.0-OpenSSH_10.2
debug1: Remote protocol version 2.0, remote software version OpenSSH_10.2
debug1: Authenticating to localhost:22 as 'root'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
<mark>debug1: kex: algorithm: mlkem768x25519-sha256</mark>
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: kex: client->server cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
debug1: SSH2_MSG_KEX_ECDH_REPLY received
debug1: Server host key: ecdsa-sha2-nistp256 SHA256:+umG5JhN8Ujjpwf0kaCdaVAQPthwIpq3inj+fOzq7I4
debug1: Host 'localhost' is known and matches the ECDSA host key.
debug1: SSH2_MSG_NEWKEYS sent
debug1: SSH2_MSG_NEWKEYS received
Authenticated to localhost ([::1]:22) using "none".
Last login: Tue Apr 14 17:01:19 2026 from ::1
</pre>

## Tested Machines

This layer has been built and booted on:

- `qemux86-64`

Other machines (including real hardware BSPs) are not yet validated.
If you try it on another target, please test and report back by opening
a PR updating this section.

## Layer Dependencies

This layer depends on:

- [`openembedded-core`](https://git.openembedded.org/openembedded-core) (`meta`) `master` branch (`poky-bleeding`)
- [`meta-openembedded`](https://github.com/openembedded/meta-openembedded/tree/master) `master` branch
- [`meta-security`](https://git.yoctoproject.org/meta-security) (`meta-security`, `meta-integrity`) `master` branch
