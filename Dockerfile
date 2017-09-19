FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m arcticcoin

ENV DAEMON_RELEASE="v0.12.1.2"
ENV ARCTICCOIN_DATA=/home/arcticcoin/.arcticcoin

USER arcticcoin

RUN cd /home/arcticcoin && \
    mkdir /home/arcticcoin/bin && \
    echo "\n# Some aliases to make the arcticcoin clients/tools easier to access\nalias arcticcoind='/usr/bin/arcticcoind -conf=/home/arcticcoin/.arcticcoin/arcticcoin.conf'\nalias arcticcoin-cli='/usr/bin/arcticcoin-cli -conf=/home/arcticcoin/.arcticcoin/arcticcoin.conf'\n" >> /home/arcticcoin/.bashrc && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone https://github.com/ArcticCore/arcticcoin.git arcticcoind && \
    cd /home/arcticcoin/arcticcoind && \
    ./autogen.sh && \
    ./configure LDFLAGS="-L/home/arcticcoin/db4/lib/" CPPFLAGS="-I/home/arcticcoin/db4/include/" && \
    make && \
    strip src/arcticcoind && \
    strip src/arcticcoin-cli && \
    strip src/arcticcoin-tx && \
    mv src/arcticcoind src/arcticcoin-cli src/arcticcoin-tx /home/arcticcoin/bin && \
    rm -rf /home/arcticcoin/arcticcoind
 
EXPOSE 7208 7209

#VOLUME ["/home/arcticcoin/.arcticcoin"]

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
    echo "\n# Some aliases to make the arcticcoin clients/tools easier to access\nalias arcticcoind='/usr/bin/arcticcoind -conf=/home/arcticcoin/.arcticcoin/arcticcoin.conf'\nalias arcticcoin-cli='/usr/bin/arcticcoin-cli -conf=/home/arcticcoin/.arcticcoin/arcticcoin.conf'\n" >> /root/.bashrc && \
    chmod 755 /home/arcticcoin/bin/arcticcoind && \
    chmod 755 /home/arcticcoin/bin/arcticcoin-cli && \
    chmod 755 /home/arcticcoin/bin/arcticcoin-tx && \
    mv /home/arcticcoin/bin/arcticcoind /usr/bin/arcticcoind && \
    mv /home/arcticcoin/bin/arcticcoin-cli /usr/bin/arcticcoin-cli && \
    mv /home/arcticcoin/bin/arcticcoin-tx /usr/bin/arcticcoin-tx

ENTRYPOINT ["/entrypoint.sh"]

CMD ["arcticcoind"]
