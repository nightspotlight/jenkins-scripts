#!/usr/bin/env bash

[ "${debug_enable}" = "true" ] && set -veuxo pipefail

api_token="username:p4ssw0rd"
jenkins_url="https://${api_token}@jenkins.example.com/job"
xslt_template="transform.xslt"
projects="$(<jobs.txt)"
projects_pre="projects_pre"
projects_post="projects_post"
curlopts="-k -s -m 60 -L"

[ ! -f ${xslt_template} ] && { echo "File ${xslt_template} not found"; exit 1; }
[[ -z ${projects} ]] && { echo "Projects list not found"; exit 1; }
[ ! -d ${projects_pre} ] && { echo "Directory ${projects_pre} not found"; exit 1; }
[ ! -d ${projects_post} ] && { echo "Directory ${projects_post} not found"; exit 1; }

usage() {
	echo "Usage: $0 download|transform|upload|rollback|all"
	exit 1
}

testurl() {
	curl ${curlopts} -I -w "%{http_code}\\n" "${jenkins_url}/${project}/" -o /dev/null
}

download() {
	echo "downloading config.xml"
	curl ${curlopts} -X GET "${jenkins_url}/${project}/config.xml" \
		-o "${projects_pre}/${project//\//-}-config.xml"
}

transform() {
	echo "transforming config.xml"
	xsltproc --output "${projects_post}/${project//\//-}-config.xml" \
		"${xslt_template}" "${projects_pre}/${project//\//-}-config.xml" \
		|| { echo "xsltproc error"; exit 1; }
}

upload() {
	echo "uploading config.xml"
	local source
	local uploadcmd
	[ "$1" = "rollback" ] && source=${projects_pre} || source=${projects_post}
	uploadcmd=$(curl ${curlopts} -w "%{http_code}\\n" -X POST \
		--data-binary "@${source}/${project//\//-}-config.xml" \
		"${jenkins_url}/${project}/config.xml" -o /dev/null)
	[ ${uploadcmd} = "200" ] && echo "OK" || { echo "error"; exit 1; }
}

for project in ${projects}; do
	if [ "$(testurl)" = "200" ]; then
		echo "processing ${project}"
		case "$1" in
			download) download;;
			transform) transform;;
			upload) upload;;
			rollback) upload rollback;;
			all) download; transform; upload;;
			*) usage;;
		esac
		echo "---------------------------------"
	else
		echo "project ${project} not found"
		echo "---------------------------------"
	fi
done
