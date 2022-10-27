FROM python:3.10-slim-bullseye

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
		git-core \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install ptvsd 
RUN set -x; \
        pip3 install debugpy

# Install additional packages
RUN set -x; \
        pip3 install wheel \
        && pip3 install py3dns \
        && pip3 install validate_email \
        && pip3 install regex

# Install hard & soft build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    apt-utils dialog \
    apt-transport-https \
    build-essential \
    libfreetype6-dev \
    libfribidi-dev \
    libghc-zlib-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    libgeoip-dev \
    libmaxminddb-dev \
    liblcms2-dev \
    libldap2-dev \
    libopenjp2-7-dev \
    libssl-dev \
    libsasl2-dev \
    libtiff5-dev \
    libxml2-dev \
    libxslt1-dev \
    libwebp-dev \
	libpq-dev \
    tcl-dev \
    tk-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Install Odoo
ARG ODOO_USER
ENV ODOO_USER ${ODOO_USER:-odoo}

ARG ODOO_VERSION
ENV ODOO_VERSION ${ODOO_VERSION:-16.0}
ARG ODOO_RELEASE
ENV ODOO_RELEASE ${ODOO_RELEASE:-20221019}

ARG POSTGRES_USER
ENV POSTGRES_USER ${POSTGRES_USER:-'odoo'}
ARG POSTGRES_PASSWORD
ENV POSTGRES_PASSWORD ${POSTGRES_PASSWORD:-'odoo'}
ARG POSTGRES_DB
ENV POSTGRES_DB ${POSTGRES_DB:-'odoodb'}
ARG DB_PORT_5432_TCP_ADDR
ENV DB_PORT_5432_TCP_ADDR ${DB_PORT_5432_TCP_ADDR:-'db'}
ARG WITHOUT_DEMO
ENV WITHOUT_DEMO ${WITHOUT_DEMO:-'all'}


RUN pip3 install --prefix=/usr/local --no-cache-dir --upgrade --requirement https://raw.githubusercontent.com/odoo/odoo/${ODOO_VERSION}/requirements.txt \
    && pip3 -qq install --prefix=/usr/local --no-cache-dir --upgrade \
    'websocket-client~=0.56' \
    astor \
    black \
    pylint-odoo \
    flake8 \
    pydevd-odoo \
    psycogreen \
    python-magic \
    python-stdnum \
    click-odoo-contrib \
    git-aggregator \
    inotify \
    python-json-logger \
    wdb \
    redis \
    reportlab \
    && apt-get autopurge -yqq \
    && rm -rf /var/lib/apt/lists/* /tmp/*

RUN mkdir -p /odoo

# Copy entrypoint script and Odoo configuration file
COPY ./startup/entrypoint.sh /odoo/startup
RUN chmod +x /odoo/startup/entrypoint.sh
COPY ./resources/odoo.conf /odoo

# Create odoo User and set permissions and Mount /odoo/dist to allow restoring filestore, /odoo/addons-custom and /odoo/addons-extra for users addons
RUN adduser --disabled-password -u 1000 --gecos '' ${ODOO_USER}

RUN mkdir -p /odoo/addons-custom \
	&& mkdir -p /odoo/addons-extra \
	&& mkdir -p /odoo/data \
	&& mkdir -p /odoo/.vscode
	
RUN chown -R ${ODOO_USER}:${ODOO_USER} /odoo
# RUN usermod ${ODOO_USER} --home /odoo/dist


VOLUME ["/odoo/data", "/odoo/addons-extra", "/odoo/addons-custom"]

# Install Odoo from source
RUN git clone --depth 100 -b ${ODOO_VERSION} https://github.com/odoo/odoo.git /odoo/dist \
    && pip3 install --editable /odoo/dist \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Implement remote-attach hook for debugging
RUN set -x; \
        echo "import debugpy" >> /odoo/dist/odoo/__init__.py \
        && echo "debugpy.listen(('0.0.0.0', 3000))" >> /odoo/dist/odoo/__init__.py
        # && echo "debugpy.wait_for_client()" >> /odoo/dist/odoo/__init__.py \
        # && echo "debugpy.breakpoint()" >> /odoo/dist/odoo/__init__.py

# Set the default config file
ENV ODOO_RC /odoo/odoo.conf

COPY ./startup/wait-for-psql.py /odoo/startup/wait-for-psql.py
RUN chmod +x /odoo/startup/wait-for-psql.py

USER ${ODOO_USER}

ENTRYPOINT ["/odoo/startup/entrypoint.sh"]

CMD ["/odoo/dist/odoo"]
