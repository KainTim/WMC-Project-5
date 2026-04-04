FROM node:lts-alpine AS build

WORKDIR /usr/src/app

# Copy package.json
COPY package.json ./

# Install dependencies
RUN yarn install --production

# Copy all files
COPY . .

RUN yarn run build

FROM node:lts-alpine
WORKDIR /usr/src/app

COPY package.json ./
COPY --from=build /usr/src/app/dist ./dist

RUN yarn install --production
# Expose port 3000
EXPOSE 3000

# Run app
CMD [ "node", "dist/app.js" ]