#!/bin/bash


echo ">>> Iniciando el aprovisionamiento del servidor DHCP..."

echo ">>> Actualizando paquetes e instalando isc-dhcp-server..."
apt-get update >/dev/null 2>&1
apt-get install -y isc-dhcp-server >/dev/null 2>&1


echo ">>> Configurando el servicio DHCP..."
mv /tmp/dhcpd.conf /etc/dhcp/dhcpd.conf
mv /tmp/isc-dhcp-server /etc/default/isc-dhcp-server


chown root:root /etc/dhcp/dhcpd.conf
chown root:root /etc/default/isc-dhcp-server


echo ">>> Reiniciando el servicio DHCP..."
systemctl restart isc-dhcp-server.service


echo ">>> Verificando estado del servicio isc-dhcp-server..."
systemctl is-active --quiet isc-dhcp-server && echo ">>> El servicio DHCP está ACTIVO y funcionando." || echo ">>> ¡ERROR! El servicio DHCP falló al iniciar."

echo ">>> Aprovisionamiento del servidor DHCP completado."