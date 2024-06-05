BEGIN { j=1 }
/<div class="flexmain"><div class="menuleft"><div class="nadpismenu">Osobní auta<\/div>/ {
getline
getline
getline
	split($0, ar, /<a href="/)
	split(ar[2], ar1, /"/)
	gsub("/", "", ar1[1])
	printf("marque_name[%d]=\"%s\";\n", j, ar1[1])
j++
	nb=24
	for(i=1;i<=nb;i++) {
	getline
	split($0, ar, /<a href="/)
	split(ar[2], ar1, /"/)
	gsub("/", "", ar1[1])
	printf("marque_name[%d]=\"%s\";\n", j, ar1[1])
		j++
	}
	getline 
	getline 
	split($0, ar, /"https:\/\/elektro.bazos.cz\//)
	split(ar[2], ar1, /\//)
	gsub("/", "", ar1[1])
	printf("marque_name[%d]=\"%s\";\n", j, ar1[1])
		j++
	getline
	split($0, ar, /"https:\/\/pc.bazos.cz\//)
	split(ar[2], ar1, /\//)
	gsub("/", "", ar1[1])
	printf("marque_name[%d]=\"%s\";\n", j, ar1[1])
		j++
	nb=6
	for(i=1;i<=nb;i++) {
	getline
	split($0, ar, /<a href="/)
	split(ar[2], ar1, /"/)
	gsub("/", "", ar1[1])
	printf("marque_name[%d]=\"%s\";\n", j, ar1[1])
		j++
	}

        exit
}
END {
        print "max_marque="j""
}