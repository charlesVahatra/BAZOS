BEGIN { c=1}
/<div class="inzeratycena"><b>/{
		split($0,ar,/<div class="inzeratycena"><b>/)
		split(ar[2],ar1,/<\/b><\/div>/)
		gsub("[^0-9]", "", ar1[1])
        val["PRIX", c]=ar1[1]
		c++
	}
/<div class="inzeraty inzeratyflex">/{
	getline
	getline
	split($0, ar, /<a href="/)
	split(ar[2], ar1, /">/)
	val["ANNONCE_LINK", c]="https://auto.bazos.cz"ar1[1]
}
/<span onclick="odeslatakci\('category','/{
	split($0, ar, /<span onclick="odeslatakci\('category','/)
	split(ar[2], ar1, /'/)
	val["ID_CLIENT", c]=ar1[1]
}

END {
	max_c=c
	for(c=1;c<max_c; c++) {	
		for(i=1; i<max_i; i++) {
			gsub("\r|\t", "", val[title[i], c])
			gsub("\"", "", val[title[i], c])
			printf("%s\t", trim(val[title[i], c])) 					
		}
		printf("\n")
	}
}

function ltrim(s) {
	gsub("^[ \t]+", "", s);
	return s
}

function rtrim(s) {
	gsub("[ \t]+$", "", s);
	return s
}

function trim(s) {
	return rtrim(ltrim(s));
}

