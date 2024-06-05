BEGIN { FS="\t" }
        {
                id++
                gsub("\"", "\\\"", $0)
                gsub("\\\\\\\\\"", "\\\"", $0)

                print "insert into "table" (listes) values ("id");";
                printf "update "table" set "
                for(i=1; i<max_i; i++) {
                        gsub("^[ \t]+", "", $i)
                        gsub("[ \t]+$", "", $i)
                        printf ("%s=\"%s\",", title[i], $i)
                }
                printf (" site=\"bazos\" where VO_ANNONCE_ID=%s;\n", id, id)
        }
