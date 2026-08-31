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

---

## 🔌 Exposed Ports

| Protocol | Container Port | Description |
| :--- | :--- | :--- |
| **IMAP** | `1143` | ProtonMail IMAP server |
| **SMTP** | `1025` | ProtonMail SMTP server |
| **CardDAV** | `8080` | ProtonMail CardDAV server |

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
