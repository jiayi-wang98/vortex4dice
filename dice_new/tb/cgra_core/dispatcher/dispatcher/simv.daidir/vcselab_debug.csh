#!/bin/csh -f

cd /data/jwang710/dice-rtl/tb/cgra_core/dispatcher/dispatcher

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/data/eda_tools/synopsys/tools/vcs/T-2022.06/linux64/bin/vcselab $* \
    -o \
    simv \
    -nobanner \

cd -

