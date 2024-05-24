#This awk file will assume that total is in first line of main.csv. rest logic is typical.

BEGIN{
    FS=",";
    OFS=",";
}
{
    s=0
    if(NR==1){
        print $0
    }
    if(NR>1){
        for (i=3;i<NF;i++){
            s+=$i
        }
        for(i=1;i<NF;i++){
            printf "%s%s", $i, (i==NF-1)?","s"\n":","
        }
    }
}