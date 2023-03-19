#!/bin/bash
#一键部署Hexo环境以及恢复Blog数据
####使用步骤
#修改currentPath变量为你想要恢复到的目录下
#放置`博客备份文件`至currentPath目录下（可以是git clone的文件夹，也可以是下载的压缩包）
#设置`博客备份文件`的文件名称
#运行脚本 脚本可以使用两个参数，一个是restart
####
blog="myblog"                                                             #博客数据包解压后的文件夹名
currentPath=$PWD                                                          #博客所在目录
dataFile='blog-source.zip'                                                #可定义数据文件名
nodeurl="https://nodejs.org/dist/v16.16.0/node-v16.16.0-linux-x64.tar.xz" # nodejs版本链接（可自定义）
####用于git配置
email=asucanyh-cn@outlook.com
username=asucanyh-cn
remoteRepo=blog-source
####
function checkParams() {
  if [ "$#" -eq 2 ]; then
    if [ "${#2}" -lt 3 ]; then
      echo -e "[Error]Please check your parameter for dataFile!\n"
      exit 17
    fi
    dataFile=$2
  fi
}
function restart() {
  echo -e "\n[Info]Cleaning nodejs & $blog..."
  nohup rm -rf $currentPath/nodejs &>/dev/null
  nohup rm -rf $currentPath/$blog &>/dev/null
  sleep 1
}
function clean() {
  #清除所有无用的文件
  echo "Cleaning Starting..."
  if [ ! -e $currentPath/nodejs.tar.xz -a ! -e $currentPath/$dataFile ]; then
    echo "[Note]Files not exist."
  fi
  if [ -e $currentPath/nodejs.tar.xz -a -e $currentPath/$dataFile ]; then
    nohup rm -f $currentPath/nodejs.tar.xz &>/dev/null
    nohup rm -f $currentPath/$dataFile &>/dev/null
    echo -e "[Info]Compressed files was cleaned."
  fi
  if [ -e $currentPath/nodejs.tar.xz ]; then
    nohup rm -f $currentPath/nodejs.tar.xz &>/dev/null
    echo -e "[Info]nodejs.tar.xz was cleaned."
  fi
  if [ -e $currentPath/$dataFile ]; then
    nohup rm -f $currentPath/$dataFile &>/dev/null
    echo -e "[Info]$dataFile was cleaned."
  fi

}
function checkOS() {
  ####检查当前操作系统
  echo -e "Recovery starting..."
  OS=$(cat /etc/os-release | grep ^NAME=".*" | awk -F "\"" '{print $2}')
  if [ "$OS" == "CentOS Linux" -o "$OS" == "CentOS" ]; then
    pkgm="yum"
  elif [ "$OS" == "Ubuntu" ]; then
    pkgm="apt-get"
  fi
  nohup sudo $pkgm update -y --skip-broken &>/dev/null
}
function env() {
  ## 安装git
  nohup $pkgm install -y git &>/dev/null
  if [ "$?" -eq 0 ]; then
    echo -e "[Info]'git' installed successfully!"
  else
    echo -e "\n[Error]Please check 'git'\n"
    exit 19
  fi

  ## 安装wget
  nohup $pkgm install -y wget &>/dev/null
  if [ "$?" -eq 0 ]; then
    echo -e "[Info]'wget' installed successfully!"
  else
    echo -e "\n[Error]Please check 'wget'\n"
    exit 28
  fi
  if [ ! -e "nodejs" -a ! -e "nodejs.tar.xz" ]; then
    wget $nodeurl -O nodejs.tar.xz
  fi
  if [ ! -e "nodejs" -a -e "nodejs.tar.xz" ]; then
    tar -xf $currentPath/nodejs.tar.xz
    mv $(find $currentPath -name node-v[0-9]*) $currentPath/nodejs
  fi
  # 重新创建nodejs软链接
  ###
  rm -rf /usr/local/nodejs
  mv $currentPath/nodejs /usr/local
  ###
  rm -f /usr/local/bin/node
  ln -s /usr/local/nodejs/bin/node /usr/local/bin/node
  rm -f /usr/local/bin/npm
  ln -s /usr/local/nodejs/bin/npm /usr/local/bin/npm
  if [ "$?" -eq 0 ]; then
    nohup node -v &>/dev/null
  fi
  if [ "$?" == 0 ]; then
    echo -e "[Info]'nodejs' installed successfully!"
  else
    echo -e "\n[Error]Please check 'nodejs'\n"
    exit 44
  fi
  ## npm
  if [ "$?" -eq 0 ]; then
    nohup npm -v &>/dev/null
  fi
  if [ "$?" == 0 ]; then
    echo -e "[Info]'npm' installed successfully!"
  else
    echo -e "\n[Error]Please check 'npm'\n"
    exit 57
  fi
  ## 安装Hexo
  nohup hexo &>/dev/null
  if [ "$?" -ne 0 ]; then
    nohup npm install --location=global hexo-cli &>/dev/null
  fi
  ### 链接hexo命令至环境变量中
  rm -f /usr/local/bin/hexo
  ln -s /usr/local/nodejs/lib/node_modules/hexo-cli/bin/hexo /usr/local/bin/hexo
}
function unzip() {
  if [ "$#" -eq 1 ]; then
    echo -e "[Note]Please specify the datafile."
    exit 25
  fi
  ## 还原数据
  ### 解压数据包 并修改文件夹为$blog
  if [ ! -d "$currentPath/$blog" ]; then
    if [ "${dataFile:0-3}" == ".gz" ]; then
      tar -xf $currentPath/$dataFile
      if [ "$?" -eq 0 ]; then
        mv $currentPath/${dataFile%*.tar.gz} $currentPath/$blog
      fi
    elif [ ${dataFile:0-3} == 'zip' ]; then
      nohup $pkgm install zip -y &>/dev/null
      nohup unzip $currentPath/$dataFile &>/dev/null
      if [ "$?" -eq 0 ]; then
        mv $currentPath/${dataFile%*.zip} $currentPath/$blog
      fi
    fi
  fi
  if [ -d $currentPath/$blog ]; then
    echo -e "[Info]Now,you can switch to '$blog' and use 'hexo server' to preview your site!\n[Note]Done"
  else
    echo -e "\n[Error]Please check 'tar -xf $dataFile or 'unzip $dataFile.'\n"
    exit 80
  fi
}
function gitConfig() {
  git config --global user.email "$email"
  git config --global user.name "$username"
  git config --global credential.helper store
  git config --global http.sslVerify false
  git config --global init.defaultBranch main
}
function repairNPM() {
  cd $blog
  echo -e "[Info]Repairing the errors."
  rm -rf node_modules && nohup npm install --force &>/dev/null
  rm -rf .deploy_git/
  # git config --global core.autocrlf false
  cd ../
  echo -e "[Info]Errors repaired."
}
function initGit() {
  cd $blog
  git init
  git add .
  git remote add origin https://github.com/$username/$remoteRepo.git
  git remote update
  git checkout main
  cd ../
}

##main
checkParams
case $1 in
"start")
  checkOS
  env
  gitConfig
  unzip
  ;;
"env")
  checkOS
  env
  gitConfig
  ;;
"restart")
  checkOS
  env
  gitConfig
  restart
  unzip
  ;;
"unzip")
  unzip
  ;;
"repair")
  repairNPM
  ;;
"init")
  initGit
  ;;
"clean")
  clean
  ;;
"help")
  echo -e "Usage: <Command> [OPTION] [FILE]"
  echo -e "    env:     Only install the necessary utils."
  echo -e "    repair:  Repair npm module errors."
  echo -e "    init:    Link the remote reposity with local reposity."
  echo -e "    unzip:   Only unpack the datafile."
  echo -e "    clean:   Clean the necessary files."
  echo -e "    start:   Start recovery nomarlly."
  echo -e "    restart: Reinstall nodejs and re-unzip your blog.\n"
  ;;
*)
  echo "[!] invalid input"
  echo "[Note]Try 'help' for more information."
  ;;
esac
