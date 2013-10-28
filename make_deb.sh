#!/bin/bash

NAME=estatsd
DESCRIPTION="is a statsd implementation in Erlang"

if [ -n "$1" ]; then
	working_dir=${1}
else
	working_dir=$(dirname $0)
fi

cd ${working_dir}

output_dir=/tmp
git_version=$(git log -10 --no-decorate | grep -i release | grep -Po -m1 "(\d+\.?)+([a-z]+)?")
git_sha=$(git log -1 --no-decorate | head -1 | cut -d" " -f2)

build_dir=${output_dir}/${NAME}_${git_version}
rm -rf ${build_dir} && mkdir -p ${build_dir}/DEBIAN ${build_dir}/etc/init.d ${build_dir}/usr/lib ${build_dir}/etc/${NAME}
cp -r ${working_dir}/release/${NAME} ${build_dir}/usr/lib/
installed_size=$[$(du -s ${build_dir}/usr | cut -f1)+16]

write_control() {
cat << EOF | sed -s "s/%INSTALLED_SIZE%/${installed_size}/g;s/%GIT_VERSION%/${git_version}/g;s/%GIT_SHA%/${git_sha}/g" > ${build_dir}/DEBIAN/control
Package: ${NAME}
Priority: extra
Section: chitika
Maintainer: Anastas Semenov <asemenov@chitika.com>
Architecture: amd64
Installed-Size: %INSTALLED_SIZE%
Version: %GIT_VERSION%-1
Provides: ${NAME}
Replaces: ${NAME}
Description: ${NAME^} ${DESCRIPTION}
 .
 git version %GIT_SHA%
Tag: implemented-in::erl, role::server
EOF
}

write_conffiles() {
cat << EOF > ${build_dir}/DEBIAN/conffiles
/etc/${NAME}/cluster.config
EOF
}

write_init_base64() {
cat << EOF | base64 -d | xz -d | sed -s "s/%NAME%/${NAME}/g;s/%VERSION%/${git_version}/g" > ${build_dir}/etc/init.d/${NAME}
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
EOF

chmod 744 ${build_dir}/etc/init.d/${NAME}
}

write_config() {
cat << EOF > ${build_dir}/etc/${NAME}/cluster.config
[
 %% SASL config
 {estatsd, [
   {flush_interval,  10000},
   {vm_metrics,      true},
   {destination,     {graphite, "localhost", 2003}}
 ]},
 {sasl, [
   {sasl_error_logger,       {file, "log/sasl-error.log"}},
   {errlog_type,              error},
   {error_logger_mf_dir,      "log/sasl"}, % Log directory
   {error_logger_mf_maxbytes, 10485760},   % 10 MB max file size
   {error_logger_mf_maxfiles, 5}           % 5 files max
 ]}
].
EOF
}

build_deb() {
dpkg -b ${build_dir} ${output_dir}/${NAME}_${git_version}-1_amd64.deb
}

write_control
write_conffiles
write_config
write_init_base64

if build_deb; then
	echo "Debian package generated: ${output_dir}/${NAME}_${git_version}-1_amd64.deb"
	rm -rf ${build_dir}
	exit 0
else
	echo "Failed to generate Debian package, sorry.."
	exit 1
fi

