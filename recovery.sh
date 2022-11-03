#!/bin/bash
#一键部署Hexo环境以及恢复Blog数据
####
blog="myblog" #博客数据包解压后的文件夹名
currentPath="/home/www" #博客所在目录
dataFile="[0-9]*_[0-9]*.tar.gz" #可定义数据文件名
nodeurl="https://nodejs.org/dist/v16.16.0/node-v16.16.0-linux-x64.tar.xz" # nodejs版本链接（可自定义）
####
if [ "$1" == "restart" -o "$2" == "restart" ];then
  echo -e "\nNote: Cleaning nodejs & $blog..."
  nohup rm -rf $currentPath/nodejs &>/dev/null
  nohup rm -rf $currentPath/$blog &>/dev/null
  sleep 1
fi
####检查当前操作系统
echo -e "Recovery starting..."
OS=`cat /etc/os-release|grep ^NAME=".*"|awk -F "\"" '{print $2}'`
if [ "$OS" == "CentOS Linux" -o "$OS" == "CentOS" ];then
  pkgm="yum"
elif [ "$OS" == "Ubuntu" ];then
  pkgm="apt-get"
fi
nohup sudo $pkgm update -y --skip-broken &>/dev/null
####
## git
nohup $pkgm install -y git &>/dev/null
if [ "$?" == 0 ];then
	echo -e "Note: 'git' installed successfully!"
else
	echo -e "\nError: Please check 'git'\n"
  exit 19
fi

## wget
nohup $pkgm install -y wget &>/dev/null
if [ "$?" == 0 ];then
	echo -e "Note: 'wget' installed successfully!"
else
	echo -e "\nError: Please check 'wget'\n"
  exit 28
fi
if [ ! -e "nodejs" -a ! -e "nodejs.tar.xz" ];then
    wget $nodeurl -O nodejs.tar.xz
fi
if [ ! -e "nodejs" -a -e "nodejs.tar.xz" ];then
    tar -xf $currentPath/nodejs.tar.xz
    mv `find $currentPath -name node-v[0-9]*` $currentPath/nodejs
fi
# 重新创建nodejs软链接
rm -f /usr/local/bin/node
ln -s $currentPath/nodejs/bin/node /usr/local/bin/node
rm -f /usr/local/bin/npm
ln -s $currentPath/nodejs/bin/npm /usr/local/bin/npm
if [ "$?" -eq 0 ];then
echo -e "Note: nodejs"
node -v
fi
if [ "$?" == 0 ];then
	echo -e "Installed successfully!"
else
	echo -e "\nError: Please check 'nodejs'\n"
  exit 44
fi
## npm
if [ "$?" -eq 0 ];then
echo -e "Note: npm"
npm -v
fi
if [ "$?" == 0 ];then
	echo -e "Installed successfully!"
else
	echo -e "\nError: Please check 'npm'\n"
  exit 57
fi
## 安装Hexo
nohup hexo &>/dev/null
if [ "$?" -ne 0 ];then 
  echo ""
  nohup npm install --location=global hexo-cli &>/dev/null
fi
### 链接hexo命令至环境变量中
rm -f /usr/local/bin/hexo
ln -s $currentPath/nodejs/lib/node_modules/hexo-cli/bin/hexo /usr/local/bin/hexo

## 还原数据
### 解压数据包

if [ "$?" -ne 0 ];then
  echo "Error: Please check Your 'DataFile'!"
elif [ ! -e $blog ];then
	tar -xf $dataFile
fi
if [ "$?" -eq 0 ];then
  echo -e "Note: Now,you can switch to '$blog' and use 'hexo server' to preview your site!\nDone"
  else 
  echo -e "\nError: Please check 'tar -xf <dataFile>.'\n"
  exit 80
fi
if [ "$1" == "clean" -o "$2" == "clean" ];then
  echo "Cleaning Starting..."
  if [ ! -e $currentPath/nodejs.tar.xz -a ! -e $currentPath/$dataFile ];then
    echo "Note: Files not exist."
  fi
  if [ -e $currentPath/nodejs.tar.xz -a -e $currentPath/$dataFile ];then
 		nohup rm -f $currentPath/nodejs.tar.xz &>/dev/null
 		nohup rm -f $currentPath/$dataFile &>/dev/null
		echo -e "Note: Compressed files was cleaned."
  fi
  if [ -e $currentPath/nodejs.tar.xz ];then
 		nohup rm -f $currentPath/nodejs.tar.xz &>/dev/null
		echo -e "Note: Compressed files was cleaned."
  fi
  if [ -e $currentPath/$dataFile ];then
		nohup rm -f $currentPath/$dataFile &>/dev/null
		echo -e "Note: Compressed files was cleaned."
  fi
fi