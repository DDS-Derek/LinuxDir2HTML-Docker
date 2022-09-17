#!/bin/bash

setting_file=/setting.lock
log_dir=/out/logs
out_html_dir=/out/html
out_dir=/out
scan_dir=/Scan
supervisor_log_dir=/out/logs/supervisor
crontab_log_file=/out/logs/crontab.log
nginx_log_file=/out/logs/nginx.log

function setting {

    touch $setting_file

    # 创建文件和文件夹
	if [ ! -d $out_dir ]; then
		mkdir -p $out_dir
	fi

	if [ ! -d $log_dir ]; then
		mkdir -p $log_dir
	fi

	if [ ! -d $out_html_dir ]; then
		mkdir -p $out_html_dir
	fi

	if [ ! -d $scan_dir ]; then
		mkdir -p $scan_dir
	fi

	if [ ! -d $supervisor_log_dir ]; then
		mkdir -p $supervisor_log_dir
	fi

	if [ ! -f $crontab_log_file ]; then
		touch $crontab_log_file
	fi

	if [ ! -f $nginx_log_file ]; then
		touch $nginx_log_file
	fi

    # 设置时区
    ln -sf /usr/share/zoneinfo/$TZ   /etc/localtime
    echo $TZ > /etc/timezone

    # 设置Crontab定时任务
    (crontab -l ; echo "${CRON} su-exec ${PUID}:${PGID} linuxdir2html /Scan /out/html/index") | crontab -

}

if [ ! -f $setting_file ]; then
	setting
fi

chown ${PUID}:${PGID} $out_dir $scan_dir $log_dir $out_html_dir
umask ${UMASK}
echo -e "\033[32m以PUID=${PUID},PGID=${PGID},umask=${UMASK}的身份启动程序\033[0m"

echo -e "\033[32mCron 定时任务预览\033[0m"
crontab -l

echo -e "\033[34m测试linuxdir2html程序\033[0m"
su-exec ${PUID}:${PGID} linuxdir2html /Scan /out/html/index

echo -e "\033[32m正式启动\033[0m"
exec /usr/bin/supervisord -n -c /app/supervisord.conf
