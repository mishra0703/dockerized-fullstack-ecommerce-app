# MERN E-Commerce Store

A full-stack e-commerce web application built with the MERN stack and fully Dockerized for production deployment.

![Docker](https://img.shields.io/badge/Docker-ready-blue?logo=docker)
![Node.js](https://img.shields.io/badge/Node.js-20-green?logo=node.js)
![MongoDB](https://img.shields.io/badge/MongoDB-7-green?logo=mongodb)
![Redis](https://img.shields.io/badge/Redis-7-red?logo=redis)

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
ACCESS_TOKEN_SECRET=our_random_secret
REFRESH_TOKEN_SECRET=our_random_secret

# Cloudinary (https://cloudinary.com → Dashboard)
CLOUDINARY_CLOUD_NAME=our_cloud_name
CLOUDINARY_API_KEY=our_api_key
CLOUDINARY_API_SECRET=our_api_secret

# Stripe (https://dashboard.stripe.com → Developers → API Keys)
STRIPE_SECRET_KEY=sk_test_...

# Our app's public URL (used for Stripe redirect URLs)
CLIENT_URL=http://our-ec2-server-public-ip:5000
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

Dockerized and extended by [Prem Mishra](https://github.com/mishra0703) — added multi-stage Dockerfile, Docker Compose with healthchecks, named volumes, and production deployment setup on AWS EC2.
