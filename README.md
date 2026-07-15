# MERN E-Commerce Store

A full-stack e-commerce web application built with the MERN stack, fully Dockerized, and shipped through an automated CI/CD pipeline with built-in DevSecOps controls — vulnerability scanning, secret detection, and least-privilege permissions enforced on every push.



[![CI Pipeline](https://github.com/mishra0703/dockerized-fullstack-ecommerce-app/actions/workflows/main-pipeline.yml/badge.svg)](https://github.com/mishra0703/dockerized-fullstack-ecommerce-app/actions/workflows/main-pipeline.yml)


[![Deploy App](https://github.com/mishra0703/dockerized-fullstack-ecommerce-app/actions/workflows/deploy.yml/badge.svg)](https://github.com/mishra0703/dockerized-fullstack-ecommerce-app/actions/workflows/deploy.yml) 


[![Scheduled HealthCheck](https://github.com/mishra0703/dockerized-fullstack-ecommerce-app/actions/workflows/health-check.yml/badge.svg)](https://github.com/mishra0703/dockerized-fullstack-ecommerce-app/actions/workflows/health-check.yml)


![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-20-339933?logo=node.js&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-7-47A248?logo=mongodb&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-7-DC382D?logo=redis&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=githubactions&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-image_scanning-1904DA?logo=aquasecurity&logoColor=white)

---

## Docker Hub

```bash
docker pull mishra0703/ecommerce-app
```

[hub.docker.com/r/mishra0703/ecommerce-app](https://hub.docker.com/r/mishra0703/ecommerce-app)

---

## What This App Does

A production-ready e-commerce platform with full shopping and admin functionality:

- **Authentication** — JWT-based login/signup with access token + refresh token flow. Tokens stored in httpOnly cookies, refresh tokens cached in Redis
- **Product Catalog** — Browse products by category, view featured products (cached in Redis for performance)
- **Shopping Cart** — Add/remove items, persistent cart per user
- **Payments** — Stripe checkout integration with success/cancel handling
- **Coupon System** — Per-user discount coupons applied at checkout
- **Product Recommendations** — Suggested products on the cart page
- **Admin Dashboard** — Create/delete products with Cloudinary image uploads, toggle featured products, view sales analytics

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React, Vite, Tailwind CSS |
| Backend | Node.js, Express |
| Database | MongoDB |
| Cache / Sessions | Redis |
| Payments | Stripe |
| Image Storage | Cloudinary |
| Containerization | Docker, Docker Compose |
| CI/CD | GitHub Actions |
| Security Scanning | Trivy, GitHub Dependency Review, GitHub Secret Scanning & Push Protection |

---

## CI/CD & DevSecOps Pipeline

Every push and pull request runs through an automated pipeline built entirely with reusable GitHub Actions workflows. Security gates are enforced at each stage — a vulnerable dependency or a critical container vulnerability blocks the pipeline before an image ever reaches Docker Hub.

```
Pull Request opened
  └─ Build & test
  └─ Dependency vulnerability review   (blocks PR on vulnerable packages)
  └─ PR checks pass / fail

Merge to main
  └─ Build & test
  └─ Docker image build
  └─ Trivy image scan                 (fails the pipeline on CRITICAL vulnerabilities)
  └─ Push to Docker Hub               (only runs if the scan passes)
  └─ Deploy                           (environment: production)

Always active, repo-wide
  └─ GitHub secret scanning
  └─ Push protection for secrets       (blocks commits containing exposed credentials)
```

**Design decisions worth noting:**

- **Reusable workflows** — build/test, Docker build, and image scanning are each isolated into their own reusable `.yml` files and composed together in a single orchestrating pipeline, rather than duplicating steps across jobs.
- **Fail-closed image publishing** — the image is built locally on the runner, scanned by Trivy in place, and only pushed to Docker Hub if the scan step succeeds. A failed scan halts the job before credentials are even used to authenticate with Docker Hub.
- **Least-privilege permissions** — each workflow explicitly declares the minimum `permissions:` it needs (e.g. `contents: read`, `pull-requests: write` only where a job posts PR comments), instead of relying on the broad default token scope.
- **SHA-based image tagging** — every build is tagged with both `latest` and a short commit SHA, so any image pushed to Docker Hub can be traced back to the exact commit that produced it.
- **Deployment stage** — the pipeline includes a deployment job wired up to a `production` GitHub Environment; the actual deployment target is being finalized next.

---

## Docker Architecture

```
┌─────────────────────────────────────────┐
│           Docker Network                │
│                                         │
│  ┌──────────┐    ┌──────────────────┐   │
│  │  mongo   │    │      redis       │   │
│  │ (MongoDB)│    │   (Redis cache)  │   │
│  └────┬─────┘    └────────┬─────────┘   │
│       │                   │             │
│  ┌────▼───────────────────▼─────────┐   │
│  │              app                 │   │
│  │   Node.js backend + React build  │   │
│  └──────────────────────────────────┘   │
│                   │                     │
└───────────────────│─────────────────────┘
                    │
              port 5000 (public)
```

- Only the `app` container is exposed to the outside world on port 5000
- MongoDB and Redis are only reachable internally via Docker network
- Multi-stage Dockerfile — builder stage compiles the frontend, runner stage is lean `node:20-alpine` with production deps only
- Non-root user inside the container
- Healthchecks on MongoDB and Redis — app waits until both are genuinely ready before starting
- Named volumes for data persistence across container restarts

---

## Environment Variables

Create a `.env` file in the project root. MongoDB and Redis are handled internally by Docker Compose — you only need external service credentials:

```env
# JWT Secrets (generate two random strings)
ACCESS_TOKEN_SECRET=your_random_secret
REFRESH_TOKEN_SECRET=your_random_secret

# Cloudinary (https://cloudinary.com → Dashboard)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Stripe (https://dashboard.stripe.com → Developers → API Keys)
STRIPE_SECRET_KEY=sk_test_...

# App's public URL (used for Stripe redirect URLs)
CLIENT_URL=http://your-ec2-server-public-ip:5000
```

---

## Running with Docker Compose

```bash
# 1. Clone the repository
git clone https://github.com/mishra0703/dockerized-fullstack-ecommerce-app.git
cd dockerized-fullstack-ecommerce-app

# 2. Create your .env file
# And fill in your credentials
cp .env.example .env

# 3. Build and start all services
docker compose up --build -d

# 4. Check all services are healthy
docker compose ps
```

App is now running at **http://your-ec2-server-public-ip:5000**

---

## Setting Up Admin Access

After creating an account through the app, promote it to admin via the MongoDB shell:

```bash
docker exec -it mern-mongo mongosh
```

```js
use mern-ecommerce
db.users.updateOne(
  { email: "your-email@gmail.com" },
  { $set: { role: "admin" } }
)
```

Log out and log back in — the admin dashboard will now be accessible.

---

## Testing Payments

Use Stripe's test card numbers:

| Card Number | Result |
|---|---|
| `4242 4242 4242 4242` | Payment succeeds |
| `4000 0000 0000 0002` | Card declined |

Use any future expiry date and any 3-digit CVC.

---

## Credits

This project is based on [mern-ecommerce](https://github.com/burakorkmez/mern-ecommerce) by [burakorkmez](https://github.com/burakorkmez).

Dockerized, secured, and automated by [Prem Mishra](https://github.com/mishra0703) — added a multi-stage Dockerfile, Docker Compose with healthchecks, named volumes, and a full GitHub Actions CI/CD pipeline with dependency review, Trivy image scanning, and secret-scanning protections, deployed on AWS EC2.