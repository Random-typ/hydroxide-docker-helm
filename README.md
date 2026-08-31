# Hydroxide Container & Kubernetes Deployment

This repository provides Docker Compose and Kubernetes (Helm) deployment configurations for [Hydroxide](https://codeberg.org/emersion/hydroxide), a lightweight ProtonMail bridge (IMAP, SMTP, CardDAV).

---

## 🚀 Docker Compose Setup

### 1. Start the Container
```bash
docker compose up -d
```

### 2. Login & Authenticate Interactively
Run the `auth` command via `exec`:
```bash
docker compose exec -it hydroxide hydroxide auth <your-protonmail-username>
```

You will be prompted for:
1. ProtonMail password
2. 2FA TOTP code (if enabled)
3. Mailbox password (if applicable)

Once authenticated, Hydroxide will print your generated **Bridge Password**. Store this password safely in your mail client.

The credentials and state are saved automatically to the `hydroxide-data` persistent volume (`/root/.config/hydroxide`).

### Optional IMAP/SMTP TLS Sidecar
Hydroxide serves IMAP and SMTP without TLS. To run TLS-wrapped IMAP and SMTP with Docker Compose, place your certificate and key at `certs/tls.crt` and `certs/tls.key`, then start the TLS compose file:

```bash
docker compose -f docker-compose.tls.yml up -d
```

This exposes IMAPS on port `993`, SMTPS on port `465`, and CardDAV on port `8080`. The plaintext IMAP and SMTP ports are only exposed inside the Compose network.

---

## ☸️ Kubernetes (Helm) Setup

### 1. Install the Helm Chart
#### Clone Repo
```bash
git clone https://github.com/Random-typ/hydroxide-docker-helm.git
```
#### Enter hydroxide directory
```bash
cd hydroxide
```
#### Install with helm
```bash
helm install hydroxide ./helm/hydroxide -n hydroxide --create-namespace
```

### 2. Login & Authenticate Interactively
Execute the `auth` command inside the running pod:
```bash
kubectl exec -it deployment/hydroxide -n hydroxide -- hydroxide auth <your-protonmail-username>
```

Complete the interactive login prompt. Credentials will persist across pod restarts using the `PersistentVolumeClaim`.

### Optional IMAP/SMTP TLS Sidecar
Hydroxide serves IMAP and SMTP without TLS. The Helm chart can add a `stunnel` sidecar that terminates TLS and forwards traffic to Hydroxide over `localhost` inside the pod.

Create or provide a Kubernetes TLS Secret containing `tls.crt` and `tls.key`, then enable the sidecar:

```bash
helm upgrade --install hydroxide ./helm/hydroxide -n hydroxide --create-namespace \
  --set tls.enabled=true \
  --set tls.certificateSecretName=hydroxide-mail-tls
```

This exposes IMAPS on port `993` and SMTPS on port `465` by default. The plaintext IMAP and SMTP ports remain private to the pod when TLS is enabled.

cert-manager works with this setup. Set `spec.secretName` on your cert-manager `Certificate` to the same value used for `tls.certificateSecretName`:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: hydroxide-mail
  namespace: hydroxide
spec:
  secretName: hydroxide-mail-tls
  dnsNames:
    - mail.example.com
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
```

---

## 🔌 Exposed Ports

| Protocol | Container Port | Description |
| :--- | :--- | :--- |
| **IMAP** | `1143` | ProtonMail IMAP server |
| **SMTP** | `1025` | ProtonMail SMTP server |
| **CardDAV** | `8080` | ProtonMail CardDAV server |

When `tls.enabled=true`, IMAP and SMTP are exposed as encrypted sidecar ports instead:

| Protocol | Service Port | Description |
| :--- | :--- | :--- |
| **IMAPS** | `993` | TLS-wrapped IMAP via stunnel |
| **SMTPS** | `465` | TLS-wrapped SMTP via stunnel |

---

## ℹ️ Checking Status

To check logged-in users at any time:

**Docker Compose:**
```bash
docker compose exec hydroxide hydroxide status
```

**Kubernetes:**
```bash
kubectl exec deployment/hydroxide -n hydroxide -- hydroxide status
```
