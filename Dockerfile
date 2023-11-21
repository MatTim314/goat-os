FROM golang:1.12-alpine

ENV name="goat-os" \
    user="goat-os"
ENV project="/go/src/github.com/goat-project/${name}/" \
    homeDir="/var/lib/${user}/" \
    logDir="/var/${name}/log/" \
    outputDir="/var/${name}/output/"

LABEL application=${name} \
    description="Extracting data from Openstack" \
    maintainer="mattim314@github" 

# Install tools required for project
RUN apk add --no-cache git shadow
RUN go get -u github.com/goat-project/goat-os

# List project dependencies with Gopkg.toml and Gopkg.lock
COPY go.modbgo.sum ${project}
# Install library dependencies
WORKDIR ${project}
RUN dep ensure -vendor-only

# Create user and directories
RUN useradd --system --shell /bin/false --home ${homeDir} --create-home --uid 1000 ${user} && \
    usermod -L ${user} && \
    mkdir -p ${logDir} ${outputDir} ${templatesDir} && \
    chown -R ${user}:${user} ${logDir} ${outputDir} ${templatesDir}

# Copy the entire project and build it
COPY . ${project}
RUN go build -o /bin/${name}

# Switch user
USER ${user}

# Expose port for goat
# Unnecessary since access to goat-os is not required during data gathering
# EXPOSE 9623

# Run main command with following options:
#  -cert-file string
#        server certificate file (default "server.pem")
#  -debug
#        True for debug mode, false otherwise
#  -ip-per-file uint
#        number of IPs per json file (default 500)
#  -key-file string
#        server key file (default "server.key")
#  -listen-ip string
#        IP address to bind to (default "127.0.0.1")
#  -log-path string
#        log path
#  -out-dir string
#        output directory
#  -port uint
#        port to bind to (default 9623)
#  -storage-per-file uint
#        number of storages per xml file (default 500)
#  -templates-dir string
#        templates directory
#  -tls
#        True uses TLS, false uses plaintext TCP
#  -vm-per-file uint
#        number of VMs per template file (default 500)
CMD /bin/goat 