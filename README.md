# NetLayer - High Performance RADIUS Server

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
sudo wget https://files.netlayer.id/radius/install.sh && sudo chmod +x ./install.sh && sudo bash ./install.sh
