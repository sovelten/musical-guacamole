FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        sbcl \
        curl \
        ca-certificates \
        libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Quicklisp into /root/quicklisp
RUN curl -fsSL https://beta.quicklisp.org/quicklisp.lisp -o /tmp/quicklisp.lisp && \
    sbcl --non-interactive \
         --load /tmp/quicklisp.lisp \
         --eval '(quicklisp-quickstart:install)' \
         --eval '(sb-ext:exit :code 0)' && \
    rm /tmp/quicklisp.lisp

# Pre-warm dependencies so container start is fast
WORKDIR /app
COPY apeiron.asd .
COPY src/ src/
RUN sbcl --non-interactive \
         --load /root/quicklisp/setup.lisp \
         --eval '(push #p"/app/" asdf:*central-registry*)' \
         --eval '(asdf:load-asd #P"/app/apeiron.asd")' \
         --eval '(ql:quickload :apeiron)' \
         --eval '(sb-ext:exit :code 0)'

COPY . .

EXPOSE 8888

CMD ["sbcl", "--non-interactive", \
     "--load", "/root/quicklisp/setup.lisp", \
     "--load", "run-mud.lisp"]
