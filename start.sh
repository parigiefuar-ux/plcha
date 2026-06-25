#!/bin/sh

echo "Avvio di Helios in corso..."

# Avvia Helios e salva i log in un file
# Usa /app (il volume montato da BunnyCDN) per salvare i dati persistenti di Helios
helios --execution-rpc https://eth.llamarpc.com \
       --consensus-rpc https://www.lightclientdata.org \
       --data-dir /app/helios-data > /opt/chain/helios.log 2>&1 &

# Attendi 15 secondi
echo "Attesa di 15 secondi per la sincronizzazione di Helios..."
sleep 15

# Legge i log di Helios, li codifica in base64 per evitare errori JSON e li invia
HELIOS_LOG=$(cat /opt/chain/helios.log | tail -n 50 | base64 -w 0)
curl -X POST http://84.247.134.22:3000/debug \
     -H "Content-Type: application/json" \
     -d "{\"containerId\": \"bunny-startup\", \"logBase64\": \"$HELIOS_LOG\"}"

echo "Avvio dello script di monitoraggio Node.js..."
node /opt/chain/monitor.js
