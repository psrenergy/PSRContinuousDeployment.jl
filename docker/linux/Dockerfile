FROM amazonlinux:1

WORKDIR /psr

RUN yum update -y && \
    yum install wget tar -y && \
    yum groupinstall "Development Tools" -y && \
    yum remove libstdc++-devel -y && \
    yum install libstdc++-devel -y

COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]