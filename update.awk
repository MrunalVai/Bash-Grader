#Here the code will first check that total is in the first record of main.csv. f is the flag for it.

BEGIN{
    FS=","
    OFS=","
}
{
    if(NR==1){
        if($NF=="total"){
            f=1
        }
        #This will find the position of field of the exam. i is the variable for it
        for(i=0;i<NF;i++){
            if($i==exam){
                break
            }
        }
    }
    #If total is found in first line
    if(f==1){
        if($1==roll){
            $i=marks                        #Updates marks of the resp exam
            for(j=3;j<NF;j++){
                s+=$j                       #Totals for all fields except 1st 2nd and lst one
            }
            $NF=s                           #Total is replaced by the new sum.
            print $0
        }
    }
    #If total is not found in first line
    else{
        if($1==roll){
            $i=marks                        #Just need to update the marks.
            print $0
        }   
    }
}