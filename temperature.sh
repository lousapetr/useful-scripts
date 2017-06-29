#!/bin/bash

if [ $# -eq 1 ]
then
    value=$1
else
    echo -n "Enter the MeOH peak separation in ppm OR desired temperature in Kelvin: "
    read value 
    echo
fi

if [ $(echo "$value < 5" | bc) -eq 1 ]
then
    # value is chemical shift separation
    echo "Chemical shift separation" $value "ppm"
    T_bruker=$(echo "-23.832*$value^2-29.46*$value+403.0" | bc )
    T_cavan=$( echo "-23.87 *$value^2-29.53*$value+403.0" | bc )
    echo "Temperature by Bruker    " $T_bruker "K" "("$(bc <<< "$T_bruker-273.2")" C)"
    echo "Temperature by Cavanagh  " $T_cavan "K" "("$(bc <<< "$T_cavan-273.2")" C)"
else
    # value is temperature
    echo "Temperature desired" $value "K" "("$(bc <<< "$value-273.2")" C)"
    CS_bruker=$(echo "scale=4; (29.46 - sqrt(29.46^2 + 4*23.832*(403-$value))) / (-2 * 23.832)" | bc -l )
    CS_cavan=$( echo "scale=4; (29.53 - sqrt(29.53^2 + 4*23.87*(403-$value))) / (-2 * 23.87)" | bc -l )
    echo "Chemical shift separation by Bruker  " $CS_bruker "ppm"
    echo "Chemical shift separation by Cavanagh" $CS_cavan "ppm"
fi
