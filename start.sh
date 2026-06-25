#!/bin/sh

# Avvia Helios in background
# Usa LlamaRPC (pubblico e gratuito) per scaricare i dati grezzi.
# Helios verificherà tutto crittograficamente in locale.
helios --execution-rpc https://eth.llamarpc.com \
       --consensus-rpc https://www.lightclientdata.org \
       --rpc-port 8545 \
       --rpc-bind-ip 127.0.0.1 &

# Attendi qualche secondo per far partire Helios
sleep 5

# Avvia lo script Node.js di monitoraggio
node /app/monitor.js