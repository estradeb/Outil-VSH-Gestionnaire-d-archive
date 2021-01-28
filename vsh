#!/bin/bash 
source fonction_client

export SERVER=$2
export PORT=$3
export ARCHIVE=$4
if [[ $1 == "-list" ]]; then  
	sendmsg "comble" "list" 
elif [[ $1 == "-browse" ]]; then 
			browse_vsh
elif [[ $1 == "-extract" ]]; then
	extract $ARCHIVE
else 
	echo "cette commande n'existe pas"
fi  
	  
  	


