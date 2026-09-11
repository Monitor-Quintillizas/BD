-- Creación de la base de datos para el proyecto en parejas
CREATE DATABASE IF NOT EXISTS monitor_team_db;
USE monitor_team_db;

-- Tabla USERS
CREATE TABLE USERS (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login_at DATETIME NULL
);

-- Tabla HOSTS
CREATE TABLE HOSTS (
    host_id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(100) UNIQUE NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    operating_system VARCHAR(50),
    registered_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla METRICS
CREATE TABLE METRICS (
    metric_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    host_id INT NOT NULL,
    cpu_usage_pct DECIMAL(5,2) NOT NULL,
    ram_used_mb DECIMAL(10,2) NOT NULL,
    ram_usage_pct DECIMAL(5,2) NOT NULL,
    disk_usage_pct DECIMAL(5,2) NOT NULL,
    measured_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES HOSTS(host_id) ON DELETE CASCADE
);

-- Tabla THRESHOLDS
CREATE TABLE THRESHOLDS (
    threshold_id INT AUTO_INCREMENT PRIMARY KEY,
    host_id INT NOT NULL,
    metric_name ENUM('cpu_usage_pct', 'ram_usage_pct', 'disk_usage_pct') NOT NULL,
    comparison_operator ENUM('>', '<', '>=', '<=', '=', '!=') NOT NULL,
    threshold_value DECIMAL(5,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (host_id) REFERENCES HOSTS(host_id) ON DELETE CASCADE
);

-- Tabla ALERTS
CREATE TABLE ALERTS (
    alert_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    threshold_id INT NOT NULL,
    metric_id BIGINT NOT NULL,
    triggered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    message VARCHAR(255) NOT NULL,
    notification_status ENUM('pending', 'sent', 'acknowledged') DEFAULT 'pending',
    FOREIGN KEY (threshold_id) REFERENCES THRESHOLDS(threshold_id) ON DELETE CASCADE,
    FOREIGN KEY (metric_id) REFERENCES METRICS(metric_id) ON DELETE CASCADE
);

-- Inserción de un usuario de prueba (Contraseña simulada: 1234)
INSERT INTO USERS (username, email, password_hash) 
VALUES ('admin', 'admin@monitor.com', '$2y$10$wY9Q2Z/oH/Q8.uP51.3xOe6L8j.B.2.3.4.5.6.7.8.9.0.1.2'); 

-- Inserción de un equipo de prueba
INSERT INTO HOSTS (hostname, ip_address, operating_system)
VALUES ('Servidor-Principal', '192.168.1.100', 'Linux Mint');