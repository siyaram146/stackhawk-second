# Dockerfile

# FROM directive instructing base image to build on
FROM python:3
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install nginx vim ssh -y --no-install-recommends

COPY nginx.default /etc/nginx/sites-available/default
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir -p /opt/app \
&& mkdir -p /opt/app/pip_cache \
&& mkdir -p /opt/app/vuln_django \
&& mkdir -p /app/.profile.d

COPY Pipfile Pipfile.lock start-server.sh /opt/app/
COPY vuln_django/ /opt/app/vuln_django/vuln_django
COPY static/ /opt/app/vuln_django/static
COPY templates/ /opt/app/vuln_django/templates
COPY polls/ /opt/app/vuln_django/polls
COPY manage.py /opt/app/vuln_django/
WORKDIR /opt/app
RUN pip install pipenv \
&& pipenv install --system --deploy \
&& chown -R www-data:www-data /opt/app
# && python vuln_django/manage.py migrate
ENV DJANGO_SUPERUSER_USERNAME=admin
ENV DJANGO_SUPERUSER_PASSWORD=adminpassword
ENV DJANGO_SUPERUSER_EMAIL=admin@example.com
# RUN python vuln_django/manage.py createsuperuser --no-input \
RUN chown -R www-data:www-data /opt/app
# && python vuln_django/manage.py seed polls --number=5

EXPOSE 8020
STOPSIGNAL SIGTERM
# CMD ["/opt/app/start-server.sh"]
