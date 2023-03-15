#!/usr/bin/env bash

# git status && git add . && git commit -m "更新代码" && git push origin DownloadRemoteFile || git push

echo "###" && echo "### 当前路径及文件 ###" && echo "###"
pwd
ls -al

echo "###" && echo "### 代码块 ###" && echo "###"
curl -sSLO "https://github.com/lyk082401/lyk082401/archive/refs/heads/main.zip"
mv main.zip artifacts/
ls -al

exit 0

# 关闭sendmail的服务
service sendmail status
service sendmail stop
chkconfig sendmail off

# 开启postfix服务
service postfix status
service postfix start

# postfix start失败，执行检查命令postfix check
postfix check

# 解决：安装mysql-libs
rpm -qa|grep mysql
yum install -y mysql-libs

# 设置postfix 开机自启动
chkconfig postfix on

# 创建认证
mkdir -p /root/.certs/
echo -n | openssl s_client -connect smtp.qq.com:465 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ~/.certs/qq.crt
certutil -A -n "GeoTrust SSL CA" -t "C,," -d ~/.certs -i ~/.certs/qq.crt
certutil -A -n "GeoTrust Global CA" -t "C,," -d ~/.certs -i ~/.certs/qq.crt
certutil -L -d /root/.certs
cd /root/.certs
certutil -A -n "GeoTrust SSL CA - G3" -t "Pu,Pu,Pu"  -d ./ -i qq.crt
ll

# 配置mail.rc
(
   cat <<EOF
set from=131413688@qq.com
set smtp=smtp.qq.com
set smtp-auth-user=131413688
#授权码
set smtp-auth-password=xxxxx
set smtp-auth=login
set smtp-use-starttls
set ssl-verify=ignore
set nss-config-dir=/root/.certs
EOF
) >>/etc/mail.rc

sendmailto()
{
 # $#表示参数个数
 if [ $# -lt 2 ]; then
     echo "Error:Missing parameters"
     echo "Useage: sh mail_attachement.sh <mail-title> <attachment1> <attachment2> ..."
     exit 1
 fi
 
 FROM_EMAIL="131413688@qq.com"
 TO_EMAIL="100861008@qq.com,100861999@qq.com"
 
 #从第2个参数开始，用-a拼出要发送的附件
 first=1

 attachment=""
 for i in "$@"
 do
     if [ $first -eq 1 ]; then
         first=0
     else
         attachment="$attachment  -a  $i "
     fi
 done
 
 echo -e "`date "+%Y-%m-%d %H:%M:%S"` : Please to check the fail sql attachement." | mailx \
 -r "From: alertAdmin <${FROM_EMAIL}>" \
 $attachment \
 -s "$1" ${TO_EMAIL}
}

apt install wget -y
apt install curl -y
curl -sSLO "https://github.com/lyk082401/lyk082401/archive/refs/heads/main.zip"

sendmailto "Your file attachment" main.zip
