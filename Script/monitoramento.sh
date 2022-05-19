#!/bin/bash
echo ""
cd /opt/
echo "---------- Instalando o Prometheus ----------"
sudo apt update
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.35.0/prometheus-2.35.0.linux-amd64.tar.gz
sudo tar zxvf prometheus-2.35.0.linux-amd64.tar.gz
cd prometheus-*
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus
sudo mv prometheus promtool /usr/local/bin/
sudo mv consoles/ console_libraries/ /etc/prometheus/
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
echo "---------- Configurando Grupo e Usuario ----------"
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/  /var/lib/prometheus/
sudo chmod -R 775 /etc/prometheus/ /var/lib/prometheus/
echo "---------- Configure o serviço Systemd ----------"

sudo echo "
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Restart=always
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/prometheus.service

sudo systemctl start prometheus
sudo systemctl enable prometheus
echo ""

sleep 5

echo "---------- Instalando o Grafana ----------"
cd /opt/
echo ""
sudo apt install gnupg2
sudo wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
sudo echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list
sudo  apt update
sudo apt install grafana
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
