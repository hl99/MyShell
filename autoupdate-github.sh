#!/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: Auto update the software from GitHub 
#	Version: 2.0
#	Author: Go2do 
#	Blog: https://www.go2do.net/
#	Encoding: Unix(LF)  UTF-8  noBOM
#=================================================

sh_ver="v2.0"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"  #定义了一些字体颜色相关的局部变量
Error="${Red_font_prefix}[错误]${Font_color_suffix}"     #定义了局部变量 "Error" ，输出时显示为红色的“【错误】”字样
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"     #定义了局部变量 "Tip" ，输出时显示为红色的“【注意】”字样
Info="${Green_font_prefix}[信息]${Font_color_suffix}"    #定义了局部变量 "Info" ，输出时显示为绿色的“【信息】”字样


#******以下为预定义的变量，使用时需在脚本里面进行赋值或者人机交互时赋值******
OwnerName=""                          #设置欲下载的 GitHub 项目的所有者 
RepositoryName=""                     #设置欲下载的 GitHub 项目的仓库名称
APPName=""                            #设置软件在本地主机上的安装后的运行（进程）名称
APPath=""                             #设置软件在本地主机上的安装后的路径，可以用 which xxx 查看


#自定义 Check_root() 权限判断函数，输出信息提醒脚本需要 root 或者 sudo 权限
Check_root(){
		[[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT权限账号，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix} sudo su ${Font_color_suffix} 命令获取临时ROOT权限。" && exit 1
}

Check_pid(){
		[[ ${APPName} ]] && PID=$(ps -ef| grep "${APPName}" | grep -v "grep" | grep -v "xxx.sh" | grep -v "init.d" |grep -v "service" |awk '{print $2}') && echo  -e "${Info} 检测到 XXX 软件的运行名称为: ${APPName} 进程 PID 为：$PID " 
}

#检查系统版本及位数信息
Check_sys(){
    if [[ -f /etc/redhat-release ]]; then        
		release="centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then 
		release="debian"	
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
	    release="ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
	    release="centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
	    release="debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
	    release="ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
	    release="centos"
    fi

    bit=`uname -m`   

    echo && echo -e "${Info} 您的系统为${Green_font_prefix}[ $release ]${Font_color_suffix}；处理器架构为${Green_font_prefix}[ $bit ]${Font_color_suffix}" && echo
}

# 自定义函数 Update_Shell() 进行脚本升级判断和下载，因为链接形式基本固定的，也就比较好处理。
Update_Shell(){
#	 sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/go2do/MyShell/master/autoupdate-github.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
    sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/go2do/MyShell/master/autoupdate-github.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
   if [[ -z ${sh_new_ver} ]] ; then
        echo -e "${Error} 无法链接到目标 GitHub !" 
   else
       wget -N --no-check-certificate "https://raw.githubusercontent.com/go2do/MyShell/master/autoupdate-github.sh" && chmod +x autoupdate-github.sh
       echo -e "${Info} 脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以需要重新运行本脚本)" 
    fi
}

Check_pre_info(){
    if [[ -z ${OwnerName} ]]; then
	    echo && echo -e "${Error} 没有预设 XXX 软件在 GitHub 中的所有者名称！" && echo -n -e "${Tip}" &&  read -e -p "请输入 XXX 软件所有者信息：" OwnerName
	else
		[[ ${OwnerName} ]] &&  echo -e "${Tip} 已经设置的 XXX 软件在  GitHub 中的所有者名称为[ ${OwnerName} ]"  
	fi
    
    if [[ -z ${RepositoryName} ]]; then
	    echo && echo -e "${Error} 没有预设 XXX 软件在 GitHub 中的仓库名称！" && echo -n -e "${Tip}" &&  read -e -p "请输入 XXX 软件所在的仓库信息:" RepositoryName
	else
	    [[ ${RepositoryName} ]] &&  echo -e "${Tip} 已经设置的 XXX 软件在 GitHub 中的仓库名称为[ ${RepositoryName} ]"  
	fi
  
    if [[ -z ${APPName} ]]; then
	    echo && echo -e "${Error} 没有预设 XXX 软件安装后的运行（进程）名称！" && echo -n -e "${Tip}" &&  read -e -p "请输入 XXX 软件安装后的运行（进程）名称，直接回车将使用仓库的名称[ ${RepositoryName} ]：" APPName 
        [[ -z ${APPName} ]] && APPName=${RepositoryName}          #如果为空，即直接输入回车，则赋值APPName=${RepositoryName} 
	else
		[[ ${APPName} ]] &&  echo -e "${Tip} 已经设置的 XXX 软件安装后运行（进程）名称为[ ${APPName} ] "  
	fi
	
	
	[[ -z ${OwnerName} ]] && [[ -z ${RepositoryName} ]] &&[[ -z ${APPName} ]] && echo &&  echo -e "${Error} 项目预设（或读取）的信息设置有误！" && exit 1

	
	if [[ -z ${APPath} ]]; then
	    echo && echo  -e "${Tip} 没有预设[ ${APPName} ]软件在本地主机上的安装后的文件夹路径，建议设置"  && echo -n -e "${Tip}" && read -e -r -p "请输入[ ${APPName} ]软件的安装路径（将用于版本、PID等信息检测），形如\" /usr/bin/ \"：" APPath
	else
	    [[ ${APPath} ]] &&  echo -e "${Tip} 已经设置的 XXX 软件在本地主机上的安装后的文件夹路径为[ ${APPath} ] " 
	fi
}

#自定义函数 Check_new_ver() 首先获取现在安装的 XXX 软件的版本号，然后去抓取 GitHub 上 XXX 的最新版本号
Check_new_ver(){
    now_version=$(${APPath}${APPName} -v|awk '{print $3}')
    [[ -z ${now_version} ]] && echo -e "${Error} 第一次获取[ ${APPName} ]版本信息失败 !将进行第二次测试......" 
    [[ ${now_version} ]] && now_version="v${now_version}" && echo -e "${Info} 第一次获取的[ ${APPName} ]版本信息是 [ ${now_version} ]" && echo

    now_version=$(${APPath}${APPName} -V|awk '{print $3}') 
    [[ -z ${now_version} ]] && echo -e "${Error} 第二次获取[ ${APPName} ]版本信息失败 !" && echo
    [[ ${now_version} ]] && now_version="v${now_version}" && echo -e "${Info} 第二次获取的[ ${APPName} ]版本信息是 [ ${now_version} ]" && echo

#下载 Releases 页面，为后续分析做准备，保存的文件名为 ${OwnerName}_${RepositoryName}_releases-tmp
	wget -N -c -q -O ./${OwnerName}_${RepositoryName}_releases-tmp  https://api.github.com/repos/${OwnerName}/${RepositoryName}/releases 
	
	if [[ -s  "${OwnerName}_${RepositoryName}_releases-tmp" ]]; then
	    versionlist=$( cat ${OwnerName}_${RepositoryName}_releases-tmp | grep "tag_name"| head -n 10 | awk -F ":" '{print $2 "  "}'| sed 's/\"//g;s/,//g;s/ //g')	
		echo -e "${Info} 仓库[ ${RepositoryName} ]项目中已经 Releases 的最新前 10 版本号分别是： \n${Green_font_prefix}${versionlist}${Font_color_suffix}" && echo 
	    echo -e "${Info} 如需更多版本信息，请前往${Font_color_suffix}查看版本列表${Green_font_prefix}[ https://github.com/${OwnerName}/${RepositoryName}/releases ]${Font_color_suffix}"
        echo -n -e "${Tip}请输入要下载的仓库[ ${RepositoryName} ]项目中已经发布的版本号，" && read -e -p "直接回车自动选择最新版本:" new_version
	  
    	[[ -z ${new_version} ]] && new_version=$( echo "${versionlist}" |awk '{print $1}'|head -n 1)	
	    [[ ${new_version} ]] && get_version=$(cat  ${OwnerName}_${RepositoryName}_releases-tmp | grep "tag_name" | grep "${new_version}"| head -n 1| awk -F ":" '{print $2}'| sed 's/\"//g;s/,//g;s/ //g') 
        
		[[ -z ${get_version} ]] &&  echo -e "${Error} 您输入的${Green_font_prefix}[ ${new_version} ]${Font_color_suffix} 版本号的在仓库[ ${RepositoryName} ]项目的信息获取失败，可能版本信息有误，没有找到可用的 Releases 资源！" && exit 1
	else	
	    echo -e "${Error} 仓库[ ${RepositoryName} ]项目信息获取失败，可能项目信息设置有误，或者没有可用的 Releases 资源！" 
	    echo -e "${Error} 请查验 ${Green_font_prefix}[ https://github.com/${OwnerName}/${RepositoryName}/releases ]${Font_color_suffix} 页面是否存在！" 
		rm -rf ./"${OwnerName}_${RepositoryName}_releases-tmp"
	    exit 1
	fi
	
#	 if [[ "${now_version}" != "${new_version}" ]]; then
#	 echo -e "${Info} 发现[ ${APPName} ]已有新版本 [ ${new_version} ]，旧版本 [ ${now_version} ]"	
}


Download_XXX(){
    [[ ${new_version} ]] && echo -n -e "${Tip}" && read -e -p "是否获取[ ${APPName} ]版本号为 [ ${new_version} ]各系统平台下载链接列表? [Y/n] :" yn
    [[ -z ${yn} ]] && yn="y"          #如果为空，即直接输入回车，则赋值yn=y

#	 if [[ $yn == [Yy] ]]; then         # [Yy] 正则表达式，指匹配 Y 或者 y ，不如下面的清晰好理解  
	if [ $yn = Y ] || [ $yn  = y ]; then
        echo && echo -e "${Info} 正在获取[ ${APPName} ]版本号为 [ ${new_version} ]各系统平台下载链接列表......"&& echo   
    fi  

#先抓取对应版本的所有下载链接，然后，根据提示的系统信息及处理器架构，手动选择需要的版本类型。并记录行数，用于选择下载链接时的判断
    cat ${OwnerName}_${RepositoryName}_releases-tmp | grep -E "\"name\":|\"browser_download_url\":" | grep -e "${new_version}"| awk -F "\"" '{print $4 "   -----> " NR }' 

#  NR 是 awk 内置变量，表示读取的行数；NF 指浏览记录的域（类似于 列 ）的个数；
    
#	 tmpSum="0"      临时变量，记录下载链接行数
    tmpSum=$( cat ${OwnerName}_${RepositoryName}_releases-tmp | grep -E "\"name\":|\"browser_download_url\":" | grep -e "${new_version}"| awk 'END{print NR}')
#    echo $tmpSum
   
    echo -e "${Tip}请从以上编号中选取适合的下载链接编号！优先选择对应系统及架构的二进制包" && echo -n -e "${Tip}" && read -e -p "如果使用源码包编译时需要考虑库依赖，需要手动自行安装！" Num_DL
   [[ -z ${Num_DL} ]] || [[ ${Num_DL} -le 0 ]]|| [[ ${Num_DL} -gt ${tmpSum} ]] && echo -e "${Error} 您的选择有误,请输入正确数字！" && exit 1

# " -le " 指！数值！小于等于 ； " -gt " 指！数值！大于，这里将字符串强制视为数字进行比较，否则容易报错。
    

#根据上面选择的下载链接编号，提取最终的 download_url
    download_url=$( cat ${OwnerName}_${RepositoryName}_releases-tmp | grep -E "\"name\":|\"browser_download_url\":" | grep -e "${new_version}" | awk -F "\"" -v awkNum_DL="${Num_DL}" 'NR==awkNum_DL {print $4 }')    
    echo && [[ ${download_url} ]] && echo -e "${Info} 您选择的下载链接是：${Green_font_prefix}[ ${download_url} ]${Font_color_suffix}"
 
 # awk 的 -v 参数用于设定一个变量，只有这样才能使用 Shell 脚本里面定义的变量，注意是！！赋值！！，因此不要有空格。   

    download_filename=$(echo "${download_url}" |awk -F "/" '{print $NF }')   #使用echo 将变量 ${download_url} 转换成字符串，否则，awk 无法处理
	[[ ${download_filename} ]] && echo -e "${Info} 您选择的下载文件类型是：${Green_font_prefix}[ ${download_filename} ]${Font_color_suffix}"

   
    echo && echo -n -e "${Tip}" &&  read -e -p "是否开始下载版本为 [ ${new_version} ] 的[ ${APPName} ] ? [Y/n] :" yn1
    [[ -z "${yn1}" ]] && yn1="y"          #如果为空，即直接输入回车，则赋值yn1=y
    #if [[ $yn1 == [Yy] ]]; then         # [Yy] 正则表达式，指匹配 Y 或者 y ，不如下面的清晰好理解  
    if [ $yn1 = Y  ] || [  $yn1  =  y  ]; then
	    [[ -s  "${download_filename}""_""${new_version}" ]] && echo -e "${Error} 本地已经存在一个版本为 [ ${new_version} ] 的[ ${APPName} ] ！" 
	    [[ ! -s  "${download_filename}""_""${new_version}" ]] && wget -N -q -c --no-check-certificate ${download_url} -O  "${download_filename}""_""${new_version}" && echo -e "${Info} 版本为 [ ${new_version} ] 的[ ${APPName} ] 已经下载成功！"
	    rm -rf ./"${OwnerName}_${RepositoryName}_releases-tmp"
    else
	    rm -rf ./"${OwnerName}_${RepositoryName}_releases-tmp"
	    exit 0
    fi 
}
while true;
do
    echo && echo -e "      GitHub 一键 XXX 程序升级管理脚本 ${Red_font_prefix} [${sh_ver}] ${Font_color_suffix}
  ----Author:go2do | Blog:https://www.go2do.net ----
————————————  
 ${Green_font_prefix} 0.${Font_color_suffix} 升级本脚本
————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 下载更新  XXX
 ${Green_font_prefix} 2.${Font_color_suffix} 自动解压  XXX
 ${Green_font_prefix} 3.${Font_color_suffix} 编译更新  XXX
 ${Green_font_prefix} 4.${Font_color_suffix} 启动运行  XXX
————————————  
 ${Green_font_prefix} Q.${Font_color_suffix} 结束&退出
————————————" && echo

    echo -n -e "${Tip}"&& read -e -p "请输入数字 [0-4] 或 [Q]：" num   

    case "$num" in
        0)
        Update_Shell      #自定义的 Update_Shell 函数调用，调用函数不需要写上" () "
        ;;
        1)
        Check_pre_info      #检测必要的项目信息是否已经预设置，否则交互式读取
        Check_new_ver       #从 GitHub 获取版本信息
        Check_sys           #检查、输出操作系统及处理器架构信息
        Download_XXX        #自定义的 Download_XXX  函数调用，调用函数不需要写上" () "
        ;;
	    2)
#	    Unzip_XXX         #自定义的 Unzip_XXX 函数调用，调用函数不需要写上" () "   ！！本功能留待后续添加！！
        echo -e "${Info} ！！本功能留待后续添加！！"
	    ;;
	    3)
	    Check_root
        Check_pre_info 
	    Check_pid
#	    Install_XXX       #自定义的Install_XXX 函数调用，调用函数不需要写上" () "  ！！本功能留待后续添加！！
        echo -e "${Info} ！！本功能留待后续添加！！"
	    ;;
	    4)
	    Check_root
	    Check_pre_info 
	    Check_pid
#	     Running_XXX       #自定义的 Running_XXX 函数调用，调用函数不需要写上" () "  ！！本功能留待后续添加！！
        echo -e "${Info} ！！本功能留待后续添加！！"
        ;;
        Q)
	    echo -e "${Info} 正在结束&退出..." &&  	break 2
        ;;
	    *)
	    echo -e "${Error} 请输入正确数字 [0-4]"
        ;;
    esac

done