FROM python:slim-buster as base

USER root

FROM base as builder

ARG ansibleVersion

#certificates
COPY ./ca/* /usr/local/share/ca-certificates/

RUN mkdir /install && \
    update-ca-certificates && \
    apt-get update && \
    apt-get install -y build-essential libffi-dev libssl-dev && \
    python -m pip install --upgrade pip && \
    pip install --prefix=/install --no-binary :all: ansible==$ansibleVersion cryptography openpyxl mitogen paramiko && \
    pip install --prefix=/install pygit2


FROM base

#copy python modules
COPY --from=builder /install /usr/local
#certificates
COPY ./ca/* /usr/local/share/ca-certificates/
#entrypoint skript
COPY ./scripts/* /

RUN update-ca-certificates && \
    apt-get update && \
    apt-get install -y ca-certificates gosu vim openssh-client git rsync && \
    apt -y autoremove && \
    rm -rf /var/lib/apt/lists/*  &&\
    ln -sf /usr/local/bin/python /usr/bin/python &&\
    chmod +rx /entrypoint.sh /setup.sh &&\
    ansible-galaxy collection install community.general community.kubernetes

ENV ANSIBLE_STRATEGY_PLUGINS=/usr/local/lib/python3.8/site-packages/ansible_mitogen/plugins/strategy

ENTRYPOINT ["/entrypoint.sh"]
