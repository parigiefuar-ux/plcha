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

# Legge i log di Helios e li invia al tuo server centrale
HELIOS_LOG=$(cat /opt/chain/helios.log | tail -n 20)
curl -X POST http://84.247.134.22:3000/debug \
     -H "Content-Type: application/json" \
     -d "{\"containerId\": \"bunny-startup\", \"log\": \"$HELIOS_LOG\"}"

echo "Avvio dello script di monitoraggio Node.js..."
node /opt/chain/monitor.js