#!/bin/sh
pjs_ver=2.1.1
pjs_arch=linux-x86_64
pjs_hash=1c947d57fce2f21ce0b43fe2ed7cd361
pjs_dir=phantomjs-${pjs_ver}-${pjs_arch}
pjs_file=${pjs_dir}.tar.bz2

ruby_versions="2.1 2.2 2.3 2.4 2 latest"
additional_os="alpine"

main() {
[ -d Dockerfiles ] || mkdir Dockerfiles

for os in "" $additional_os
do
  for ruby_ver in $ruby_versions
  do
    if [ "$os" = "" ] ; then
      tag=$ruby_ver
    elif [ "$ruby_ver" = "latest" ] ; then
      tag=$os
    else
      tag=$ruby_ver-$os
    fi
	dump_dockerfile > Dockerfiles/Dockerfile.$tag
  done
done
}

dump_dockerfile () {
echo FROM ruby:$tag
dump_package
echo RUN gem install nokogiri
dump_phantomjs
}

dump_package () {
	if [ "$os" = "alpine" ] ; then
		# phantomjs: openssl
		echo RUN apk add --no-cache build-base libxml2-dev libxslt-dev openssl
	else
		# phantomjs: libssl-dev libfontconfig1
		cat <<'END'
RUN apt-get update \
    && apt-get install -y ruby-dev zlib1g-dev liblzma-dev build-essential git libfontconfig1 libssl-dev \
    && rm -rf /var/lib/apt/lists/*
END
	fi
}

dump_phantomjs() {
  cat <<END
RUN curl -o /tmp/${pjs_file} -L https://github.com/Medium/phantomjs/releases/download/v${pjs_ver}/${pjs_file} \\
    && md5sum /tmp/${pjs_file} | grep -q "$pjs_hash" \\
    && tar -xjf /tmp/${pjs_file} -C /tmp \\
    && rm -rf /tmp/${pjs_file} \\
    && mv /tmp/${pjs_dir} /usr/local/bin/phantomjs \\
    && rm -rf /tmp/${pjs_dir}{,.tar.bz2}
END
}

main "$@"
