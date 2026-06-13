# NetLayer - High Performance RADIUS Server

<p align="center">
  <img src="https://netlayer.id/assets/images/netlayer-dashboard-preview.png" alt="NetLayer Preview" width="100%">
</p>

**Official Website:** [https://netlayer.id](https://netlayer.id)

**NetLayer** is a lightweight, high-performance RADIUS server built with PHP, designed specifically for ISP (Internet Service Provider) and public hotspot management. It provides authentication, authorization, and accounting (AAA) for PPPoE and Hotspot users with enterprise-grade features.

## Key Features

- **Multi-Protocol Support**: PPPoE and Hotspot/Voucher authentication
- **High Performance**: Handles thousands of concurrent sessions with minimal resources
- **Real-time Session Management**: Active session monitoring and control
- **Revenue Tracking**: Complete billing and transaction reporting
- **User Management**: Profiles, vouchers, and user account management
- **SQLite Database**: Lightweight, no additional database server required
- **Web Dashboard**: Built-in web interface for administration
- **Low Memory Footprint**: Runs on devices with as little as 256MB RAM

## Quick Installation

```bash
sudo apt install git -y && sudo git clone https://github.com/netlayer-id/radius_server.git && cd ./radius_server && sudo chmod +x ./netlayer && sudo chmod +x ./server.sh && sudo ./server.sh
```

## Manual Execution
```bash
chmod +x ./netlayer
./netlayer
```
## Running as System Service
```bash 
chmod +x ./server.sh
./server.sh
```
### Make sure these ports are open in your firewall:
```bash
# UFW (Ubuntu/Debian)
sudo ufw allow 1812/udp
sudo ufw allow 1813/udp
sudo ufw allow 8080/tcp

# Firewalld (CentOS/RHEL)
sudo firewall-cmd --add-port=1812/udp --permanent
sudo firewall-cmd --add-port=1813/udp --permanent
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```



