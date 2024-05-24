BEGIN{
    FS=","
    OFS=","
}
{
    if(NR==1){
        print $0,"grade"                        #Updating first line of main.csv
    }
    else{
        m = $NF                                 #m will the total marks which are the last field in each record
        if(m>=aa){
            print $0,"AA"
        }
        else if(m>=ab){
            print $0,"AB"
        }
        else if(m>=bb){
            print $0,"BB"
        }
        else if(m>=bc){
            print $0,"BC"
        }
        else if(m>=cc){
            print $0,"CC"
        }
        else if(m>=cd){
            print $0,"CD"
        }
        else if(m>=dd){
            print $0,"DD"
        }
        else{
            print $0,"FF"
        }
    }
}