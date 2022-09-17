#!/bin/bash

setting_file=/setting.lock
log_dir=/out/logs
out_dir=/out
scan_dir=/Scan
crontab_log_file=/out/logs/crontab.log

function setting {

    touch $setting_file

    # 创建文件和文件夹
	if [ ! -d $out_dir ]; then
		mkdir -p $out_dir
	fi

	if [ ! -d $log_dir ]; then
		mkdir -p $log_dir
	fi

	if [ ! -d $scan_dir ]; then
		mkdir -p $scan_dir
	fi

	if [ ! -f $crontab_log_file ]; then
		touch $crontab_log_file
	fi

    # 设置时区
    ln -sf /usr/share/zoneinfo/$TZ   /etc/localtime
    echo $TZ > /etc/timezone

    # 设置Crontab定时任务
    (crontab -l ; echo "${CRON} su-exec ${PUID}:${PGID} linuxdir2html /Scan /out/index") | crontab -

    (crontab -l ; echo "0 */2 * * * chown ${PUID}:${PGID} ${crontab_log_file}") | crontab -

}

if [ ! -f $setting_file ]; then
	setting
fi

chown ${PUID}:${PGID} $out_dir $scan_dir $log_dir $crontab_log_file
umask ${UMASK}
echo "以PUID=${PUID},PGID=${PGID},umask=${UMASK}的身份启动程序"

su-exec ${PUID}:${PGID} linuxdir2html /Scan /out/index

crond -f >> $crontab_log_file