#!/bin/bash
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