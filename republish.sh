#!/bin/bash
dir=/var/www	#设置博客路径
blog=myblog		#设置博客根目录名
path=$dir/$blog	

resize=800x800	#设置压缩图片质量
qlty=50			#设置压缩图片的程度

hexo=/root/.nvm/versions/node/v16.15.1/bin/hexo	#设置hexo命令位置
gulp=/root/.nvm/versions/node/v16.15.1/bin/gulp	#设置gulp命令位置
git="/usr/bin/git" #设置git命令位置
#####################################################################################
if [ "$1" == "p" -o "$1" == "pull" ];then
echo "Note: Pulling from remote repo."
cd $path
$git pull -u origin main
fi
#0检查路径
if [ -d "$path" ]
then
	if [ pwd != "$path" ]
		then 
			cd /
	fi
else 
	echo -e "\n"
	echo "Error:$blog文件夹不存在，请检查$dir目录下是否存在该文件夹！"
    echo -e "\n"
    exit 1
fi
cd $path
echo -e "\n"
echo "成功切换至$path目录下，开始执行部署命令......"
echo -e "\n"
###
#1检查hexo是否安装
if [ ! -f "$hexo" ]
then
	echo -e "\n"
	echo "Error:请检查Hexo命令安装位置后，修改comm变量！"
    echo -e "\n"
    exit 2
else
	$hexo clean;#清除public
	$hexo g;#生成public
####
#优化css,js,html
	$gulp;
if [ "$?" -ne "0" ]
then
	echo -e "\n"
	echo "Error:请检查gulp命令！"
    echo -e "\n"
    exit 3
fi
###
#压缩图片
	echo -e "\n";
	echo "开始压缩图片...";
	echo -e "\n";
    
	find $dir/$blog/public/img/post -regex '.*\(jpg\|JPG\|png\|PNG\|jpeg\)' -size +100k -print -exec convert -resize $resize -quality $qlty {} {} \;;
if [ "$?" -ne "0" ]
then
	echo "Error:请检查压缩图片设置！"
	exit 4
fi
###

#部署到github
$hexo d
fi
if [ "$?" -eq "0" ]
then
	echo -e "\n"
	echo "Hexo已重新发布！"
    echo -e "\n"
else
	echo -e "\n"
	echo "执行失败，请检查错误！"
    echo -e "\n"
    exit 5
fi