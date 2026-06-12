FROM node:22 AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install 

COPY frontend/package*.json ./frontend/

RUN npm install --prefix frontend

COPY backend ./backend

COPY frontend ./frontend

RUN npm run build --prefix frontend




FROM node:22-alpine AS runner

WORKDIR /app

RUN addgroup -S nodejs && adduser -S nodeuser -G nodejs

COPY package*.json ./

RUN npm install --omit=dev


COPY --from=builder /app/backend ./backend

COPY --from=builder /app/frontend/dist ./frontend/dist

RUN chown -R nodeuser:nodejs /app


USER nodeuser

#ENV NODE_ENV=production

EXPOSE 5000

CMD ["node" , "backend/server.js"]


