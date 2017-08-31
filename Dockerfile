FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m arcticcoin

ENV ARCTICCOIN_DATA=/home/arcticcoin/.arcticcoin

USER arcticcoin

RUN cd /home/arcticcoin && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone https://github.com/ArcticCore/arcticcoin.git arcticcoind && \
    cd /home/arcticcoin/arcticcoind && \
    ./autogen.sh && \
    ./configure LDFLAGS="-L/home/arcticcoin/db4/lib/" CPPFLAGS="-I/home/arcticcoin/db4/include/" && \
    make 
    
EXPOSE 7208 7209

#VOLUME ["/home/arcticcoin/.arcticcoin"]

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && cp /home/arcticcoin/arcticcoind/src/arcticcoind /usr/bin/arcticcoind && chmod 755 /usr/bin/arcticcoind

ENTRYPOINT ["/entrypoint.sh"]

CMD ["arcticcoind"]
