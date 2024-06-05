BEGIN {nb_annonce=0}
/<meta http-equiv="Content-Type" content="text\/html; charset=utf-8">/ {
    getline
	split($0, ar, /" content="/)
	split(ar[2], ar1, /"/)
	    gsub("\r", "", ar1[1])
        gsub("[^0-9]", "", ar1[1])
        nb_annonce=ar1[1]
}
END{
        print ""nb_annonce""
}