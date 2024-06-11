#!/bin/bash

ExitProcess () {
        status=$1
        if [ ${status} -ne 0 ]
        then
                echo -e $usage
                echo -e $error
        fi
        find ${dir}/ -type f -name "*.$$" -exec rm -f {} \;
        exit ${status}
}

function download_pages () {
	# url
	# output 
	curl "${url}" \
	  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
	  -H 'accept-language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' \
	  -H 'cache-control: max-age=0' \
	  -H 'if-modified-since: Fri, 31 May 2024 12:57:31 GMT' \
	  -H 'priority: u=0, i' \
	  -H 'sec-ch-ua: "Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"' \
	  -H 'sec-ch-ua-mobile: ?0' \
	  -H 'sec-ch-ua-platform: "Windows"' \
	  -H 'sec-fetch-dest: document' \
	  -H 'sec-fetch-mode: navigate' \
	  -H 'sec-fetch-site: none' \
	  -H 'sec-fetch-user: ?1' \
	  -H 'upgrade-insecure-requests: 1' \
	  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36' > ${output} 
}

function download_list_multy_process (){

	nb_processus=5
	awk 'BEGIN{FS="\t"}{print "if [ ! -s "$1" ]; then url=\""$2"\"; output="$1";  download_pages ; fi"}' ${list_file} > ${dir}/${d}/LISTING/${m_rep}/wget_file.txt
    nb=`wc -l ${dir}/${d}/LISTING/${m_rep}/wget_file.txt | awk '{print $1}' `
    let "split = (nb / nb_processus) + 1"
    split -l${split} -d ${dir}/${d}/LISTING/${m_rep}/wget_file.txt  ${dir}/${d}/LISTING/${m_rep}/wget_file.txt.
    i=0
    for wget_file in `ls ${dir}/${d}/LISTING/${m_rep}/wget_file.txt.*`
    do
        echo -e "set -x\n">>${wget_file}
        . ${wget_file} >  ${dir}/${d}/LISTING/${m_rep}/LOG/log_${i} 2>&1 &
        let "i=i+1"
    done

    wait
}

function download_detail_multy_process (){
		
		nb_processus=10
		awk -vdir="${dir}/${d}/ALL/" 'BEGIN{FS="\t"}{print "if [ ! -s "dir"annonce_"$2".html ]; then url=\""$1"\"; output="dir"annonce_"$2".html;  download_pages ; fi"}' ${dir}/${d}/extract.tab  > ${dir}/${d}/wgets/wget_file.txt
		nb=`wc -l-f  ${dir}/${d}/wgets/wget_file.txt | awk '{print $1}' `
        let "split = (nb / nb_processus) + 1"
        split -l${split} -d ${dir}/${d}/wgets/wget_file.txt  ${dir}/${d}/wgets/wget_file.txt.
        i=0
        for wget_file in `ls ${dir}/${d}/wgets/wget_file.txt.*`
        do
			echo -e "set -x\n">>${wget_file}
			. ${wget_file} >  ${dir}/${d}/log_${i} 2>&1 &
			let "i=i+1"
        done
        wait
}

#
# MAIN
#
usage="download_site.sh \n\
\t-a no download - just process what's in the directory\n\
\t-d [date] (default today)\n\
\t-h help\n\
\t-i id start de la region default : 1\n\
\t-I id end de la region default : max_region\n\
\t-M [region]\n\
\t-m [modele]\n\
\t-r retrieve only, do not download the detailed adds\n\
\t-R reset : delete files to redownload\n\
\t-t table name \n\
\t-T valeurs : new used certified ex: -T\"used new\"\n\
\t-x debug mode\n\
"

date
typeset -i lynx_ind=1
typeset -i get_detail_mod=1
typeset -i get_all_ind=1
typeset -i get_list_ind=1
typeset -i nb_retrieve_per_page=20
typeset -i max_retrieve=30000
typeset -i nb_processus=5
typeset -i max_loop_1=5
typeset -i max_loop=3
Y=`date "+%Y"  --date="-366 days ago"`

while getopts :-ad:rht:xz: name
do
  case $name in

    a)  lynx_ind=0
        let "shift=shift+1"
        ;;

    d)  d=$OPTARG
        let "shift=shift+1"
        ;;

        i)      MIN_REGION_ID=$OPTARG
        let "shift=shift+1"
        ;;

    I)  MAX_REGION_ID=$OPTARG
        let "shift=shift+1"
        ;;

    M)  my_region=`echo ${OPTARG} | tr '[:lower:]' '[:upper:]' `
        let "shift=shift+1"
        ;;

        m)      my_modele=`echo $OPTARG | tr '[:lower:]' '[:upper:]' `
        let "shift=shift+1"
        ;;

    h)  echo -e ${usage}
        ExitProcess 0
        ;;

    r)  get_all_ind=0
        let "shift=shift+1"
        ;;

    t)  table=$OPTARG
        let "shift=shift+1"
        ;;

    x)  set -x
        let "shift=shift+1"
        ;;

    z)  let "shift=shift+1"
        ;;

    --) break
        ;;

        esac
done
shift ${shift}

if [ $# -ne 0 ]
        then
    error="Bad arguments, $@"
    ExitProcess 1
fi

if [ "${d}X" = "X" ]
        then
        d=`date +"%Y%m%d"`
fi
if [ "${table}X" = "X" ]
        then
        mois=$(date --date "today + `date +%d`days" +%Y_%m)
        table="bazos"`date +"%Y_%m"`
fi
if [ "${grand_table}X" = "X" ]
        then
        grand_table="VO_UK_"`date +"%Y_%m"`
fi

debut=`date +"%Y-%m-%d %H:%M:%S"`
dir=`pwd`
mkdir -p ${dir}/${d} ${dir}/${d}/LISTING ${dir}/${d}/ALL
touch ${dir}/${d}/status 

if [ ${get_list_ind} -eq 1 ]; then
	
	echo  -e "list" > ${dir}/${d}/status 
	url='https://auto.bazos.cz/'
	output=${dir}/${d}/page-0.html
	download_pages
	
	nb_site=$(awk -f ${dir}/nb_annonce.awk ${output})

	awk -f ${dir}/liste_marque.awk ${dir}/${d}/page-0.html > ${dir}/${d}/liste_marque.sql
	. ${dir}/${d}/liste_marque.sql
	echo "max_marques=${max_marque}"
	
	for (( marque=1 ; marque<=${max_marque}; marque++ ))
	# for marque in 1 3
	do 
		m_rep=${marque_name[$marque]}
		mkdir -p ${dir}/${d}/LISTING/${m_rep}  ${dir}/${d}/LISTING/${m_rep}/LOG 

		#https://auto.bazos.cz/bmw/
		output=${dir}/${d}/LISTING/${m_rep}/page_0.html
		url=https://auto.bazos.cz/${m_rep}/
		download_pages
		
		nb_site=$(awk -f ${dir}/nb_annonce.awk ${output})
		echo "nombre_site=${nb_site}"
		let "max_page=$nb_site/$nb_retrieve_per_page"
		echo "max_page=${max_page}"
		# Crawl page list
		max_page=360
		#####################
		for (( page=20; page <= ${max_page}; page+=20 ))
		do
			url=https://auto.bazos.cz/${m_rep}/${page}/
			output=${dir}/${d}/LISTING/${m_rep}/page-${page}.html
			echo -e "${output}\t${url}" >> ${dir}/${d}/LISTING/${m_rep}/$$.wget_file
		done
		list_file=${dir}/${d}/LISTING/${m_rep}/$$.wget_file
		download_list_multy_process
		
		
		echo -e "parsing list" >> ${dir}/${d}/status  
		find ${dir}/${d}/LISTING/${m_rep}/ -type f -name '*.html' -exec  awk -f ${dir}/liste_tab.awk -f ${dir}/put_html_into_tab.awk {} \; >>  ${dir}/${d}/LISTING/${m_rep}/${m_rep}.$$
		
		# Log Par Marque
		cat  ${dir}/${d}/LISTING/${m_rep}/${m_rep}.$$  | sort -u -k1,1 >  ${dir}/${d}/LISTING/${m_rep}/${m_rep}.tab
		nb_observe=`wc -l   ${dir}/${d}/LISTING/${m_rep}/${m_rep}.tab | awk '{print $1}'`
		cat  ${dir}/${d}/LISTING/${m_rep}/${m_rep}.tab  >> ${dir}/${d}/extract.$$
		echo -e "${m_rep}\t${nb_site}\t${nb_observe}\tMARQUE"
	done
			
	cat ${dir}/${d}/extract.$$ | sort -u -k1,1 >  ${dir}/${d}/extract.tab
	wait 
	awk -vtable=${table} -f ${dir}/liste_tab.awk -f ${dir}/put_tab_into_db.awk  ${dir}/${d}/extract.tab > ${dir}/${d}/VO_ANNONCE_insert.sql 
fi	

# Telechargement fiches 
if [ ${get_all_ind} -eq 1 ]; then
		
		mkdir -p ${dir}/${d}/wgets  
		rm -f  ${dir}/${d}/wgets/wget_file.* 
		download_detail_multy_process			
		# parsing fiches
		find ${dir}/${d}/ALL -type f -name "*html" -exec awk -vtable=${table} -f ${dir}/all_html.awk  {} \; >> ${dir}/${d}/VO_ANNONCE_update.sql
fi

echo -e "FIN DU TELECHARGEMENT!"
ExitProcess 0
