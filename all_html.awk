BEGIN {	
	i=1	
	title[i]="MARQUE";		i++;
	title[i]="ID_CLIENT";		i++;
	title[i]="ANNEE";		i++;
	title[i]="NOM";		i++;
	title[i]="VILLE";		i++;
	title[i]="KM";		i++;
	title[i]="VIN";		i++;	
	title[i]="PRIX";		i++;	
	title[i]="CP";		i++;
	title[i]="CYLINDRE";		i++;
	title[i]="PORTE";		i++;
	title[i]="CAROSSERIE";		i++;
	title[i]="CARBURANT";		i++;
	title[i]="TRANSMISSION";		i++;
	title[i]="PHOTO";		i++;
	max_i=i
}
# <a href="https://auto.bazos.cz/">Auto</a> > <a href="https://auto.bazos.cz/skoda/">Škoda</a> 
/<a href="https:\/\/auto.bazos.cz\/">Auto<\/a> /{
	split($0, ar, /<a href="https:\/\/auto.bazos.cz\/">Auto<\/a>/)
	split(ar[2], ar1, /<\/a>/)
	gsub(/<[^>]*>/, "", ar1[1])
	gsub(/>/, "", ar1[1])
	val["MARQUE"]=ar1[1]
	gsub("[^0-9]", "", ar1[2])
	val["ID_CLIENT"]=ar1[2]
}

/<title>/{
	split($0, ar, />/)
	split(ar[2], ar1, /-/)
	val["NOM"]=ar1[1]
	{
    if (match($0, /20[0-9][0-9]/)) {
        year = substr($0, RSTART, RLENGTH)
        # if (year == "20") {
			print year
            val["ANNEE"]=year
        # }
		}
	}
	getline
	getline
	split($0, ar, /Lokalita:/)
	split(ar[2], ar1, /"/)
	val["VILLE"]=ar1[1]
}

/<div class="listainzerat inzeratyflex">/{
	getline
	getline
	getline
	getline
	getline
	getline
	getline
	getline
	getline
	getline
	getline
	gsub("[^0-9]", "", $0)
	val["KM"]=$0
	getline
	getline
	getline
	split($0, ar, /VIN:/)
	split(ar[2], ar1, /</)
	val["VIN"]=ar1[1]
	
}
/<tr><td height="22px" width="25%"><br>Cena:<\/td><td colspan=2><br><b>/{
	split($0, ar, /<tr><td height="22px" width="25%"><br>Cena:<\/td><td colspan=2><br><b>/)
	split(ar[2], ar1, /</)
	gsub("[^0-9]", "",ar1[1])
	val["PRIX"]=ar1[1]
}
/title="Přibližná lokalita" rel="nofollow">/{
	split($0,ar,/title="Přibližná lokalita" rel="nofollow">/)
	split(ar[2],ar1,/</)
	val["CP"]=ar1[1]
}

END {	
	for (i=1; i<max_i; i++) {		
		gsub(/"|\t|\r|\n|\\/, "", val[title[i]])			
		if (trim(val[title[i]])!="")
			upd=upd" "sprintf("%s=\"%s\",", title[i], trim(val[title[i]]))	
	}
	if (upd!="")
		printf ("update %s set %s id_client=\"%s\" where site=\"bazos\" and ID_CLIENT=\"%s\";\n", table, upd, val["ID_CLIENT"], val["ID_CLIENT"])
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
