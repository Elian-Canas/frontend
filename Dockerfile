# Etapa de construcción
FROM node:16-alpine as build-stage

# Establecer directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar el archivo .env.production primero
COPY .env.production .env

# Verificar el contenido del .env
RUN echo "=== Contenido del .env ===" && cat .env

# Copiar el resto del código fuente
COPY . .

# Establecer modo producción y variables de entorno
ENV NODE_ENV=production
ARG VUE_APP_API_BASE_URL=http://localhost:8080
ENV VUE_APP_API_BASE_URL=${VUE_APP_API_BASE_URL}
# Construir la aplicación para producción
RUN NODE_ENV=production npm run build

# Verificar el contenido generado
RUN echo "=== Archivos generados ===" && ls -la dist/ && echo "=== Contenido del main.js ===" && cat dist/js/app.*.js | grep -o "http://[^']*"

# Etapa de producción
FROM nginx:stable-alpine as production-stage

# Copiar los archivos construidos desde la etapa anterior
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Exponer el puerto 80
EXPOSE 80

# Iniciar nginx
CMD ["nginx", "-g", "daemon off;"]
