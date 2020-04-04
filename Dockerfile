ARG version=3.8.5
FROM jekyll/builder:$version

MAINTAINER iwakiri.yutaro@gmail.com

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
