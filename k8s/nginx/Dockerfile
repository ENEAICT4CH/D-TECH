# pull the latest official nginx image
FROM nginx:stable

# copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# copy static
COPY ./public/ /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
