#!/bin/sh

#===================================================================================
#  zback.sh  : 定義ファイルを基にバックアップを行う。
#-----------------------------------------------------------------------------------
#  author    : miz <miz@about.me>
#  version   : 1.2
#  todo      : なし
#  
#  ChangeLog : 
#   ver 1.2    2017/08/21(月)  UTF8化。
#   ver 1.1    2014/04/02(月)  若干、整形。
#   ver 1.0    2009/04/06(月)  新規作成
#===================================================================================

readonly SUCCESS=0
readonly TRUE=0
readonly FALSE=1

main()
{

	#--------- Variable Setting
	def_path=$HOME/archive/bkupDef
	lnk_path=$HOME/archive/bkupDef/bkuplink
	bak_path=$HOME/archive/zbackDir
	bk_date=`date '+%Y%m%d'`

    tarcmd=\tar

	test  $# -eq 0  && usage

	#--------- Option Parse
	is_pass=$FALSE
	suffix=""
	while getopts 'dl' OPTION
	do
		case $OPTION in
			\?) OPT_ERROR=1; break;;
			#--------- def ファイル一覧を表示して終了
			"d" ) suffix="_$bk_date";;
			"l" ) ls -l ${def_path}/*.def && exit 0;;
		esac
	done
	shift $(expr $OPTIND - 1)

	if [ $OPT_ERROR ]; then
		usage
	fi

	dir_check

	cd ${lnk_path}

	for infile in "$@"
	do
		test ! -f ${def_path}/${infile}.def && echo -e "Not Found. ${infile}.def" && exit 1
		exec_backup
	done

	exit 0
}

function dir_check() {
	test ! -d ${def_path} && echo -e "Not Found. ${def_path}" && exit 1
	test ! -d ${lnk_path} && echo -e "Not Found. ${lnk_path}" && exit 1
	test ! -d ${bak_path} && echo -e "Not Found. ${bak_path}" && exit 1
}

function exec_backup() {

	out_file=${bak_path}/${infile}${suffix}.tar.gz
	${tarcmd} cfhz ${out_file} -T ${def_path}/${infile}.def
	if [ $? -eq $SUCCESS ]; then
		echo "  ${out_file}     を作成しました。"
	else
		echo "  ${out_file}     の作成に失敗しました。"
		exit 1
	fi
}

usage() {
	echo -e "usage:`basename $0` [-d date, -l] DEF_FILES..."
	exit 1
}

# Entry Point
main $*

