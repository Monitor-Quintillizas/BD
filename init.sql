CREATE DATABASE IF NOT EXISTS monitor_team_db;
USE monitor_team_db;

-- 1. Tabla de Usuarios del Sistema (con Roles y Seguimiento de Telemetría por Cuenta)
CREATE TABLE IF NOT EXISTS USERS (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login_at DATETIME NULL,
    last_seen_at DATETIME NULL,
    current_host VARCHAR(100) DEFAULT 'Mi Computadora',
    last_cpu DECIMAL(5,2) DEFAULT 0.00,
    last_ram DECIMAL(5,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Tabla de Equipos / Hosts Monitoreados
CREATE TABLE IF NOT EXISTS HOSTS (
    host_id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(100) UNIQUE NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    operating_system VARCHAR(50),
    registered_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Tabla de Registro Histórico de Métricas de Telemetría
CREATE TABLE IF NOT EXISTS METRICS (
    metric_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    host_id INT NOT NULL,
    cpu_usage_pct DECIMAL(5,2) NOT NULL,
    ram_used_mb DECIMAL(10,2) NOT NULL,
    ram_usage_pct DECIMAL(5,2) NOT NULL,
    disk_usage_pct DECIMAL(5,2) NOT NULL,
    measured_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES HOSTS(host_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Tabla de Umbrales Configurados por Equipo
CREATE TABLE IF NOT EXISTS THRESHOLDS (
    threshold_id INT AUTO_INCREMENT PRIMARY KEY,
    host_id INT NOT NULL,
    metric_name ENUM('cpu_usage_pct', 'ram_usage_pct', 'disk_usage_pct') NOT NULL,
    comparison_operator ENUM('>', '<', '>=', '<=', '=', '!=') NOT NULL,
    threshold_value DECIMAL(5,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (host_id) REFERENCES HOSTS(host_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Tabla de Alertas Disparadas por Superación de Umbrales
CREATE TABLE IF NOT EXISTS ALERTS (
    alert_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    threshold_id INT NOT NULL,
    metric_id BIGINT NOT NULL,
    triggered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    message VARCHAR(255) NOT NULL,
    notification_status ENUM('pending', 'sent', 'acknowledged') DEFAULT 'pending',
    FOREIGN KEY (threshold_id) REFERENCES THRESHOLDS(threshold_id) ON DELETE CASCADE,
    FOREIGN KEY (metric_id) REFERENCES METRICS(metric_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Datos Iniciales / Semillas para Pruebas (Seed Data)
-- Usuario Administrador principal con rol 'admin' (Contraseña: 1234)
INSERT INTO USERS (username, email, password_hash, role) 
VALUES ('admin', 'admin@monitor.com', '$2y$10$w4rYc0UoA/Z6U1q9L7KxO.W3j5Z8T2B4e6G8h0J2l4N6p8R0t2V4W', 'admin')
ON DUPLICATE KEY UPDATE role='admin';

-- Equipos / Hosts de prueba
INSERT INTO HOSTS (host_id, hostname, ip_address, operating_system)
VALUES 
    (1, 'Evangelin (Mi PC)', '127.0.0.1', 'Windows 11 (AMD64)'),
    (2, 'Servidor-BaseDatos', '192.168.1.101', 'Debian 12 Bookworm'),
    (3, 'Servidor-Worker', '192.168.1.102', 'Fedora 40 Server')
ON DUPLICATE KEY UPDATE hostname=VALUES(hostname);

-- Umbrales iniciales
INSERT INTO THRESHOLDS (host_id, metric_name, comparison_operator, threshold_value, is_active)
VALUES 
    (1, 'cpu_usage_pct', '>', 80.00, TRUE),
    (1, 'ram_usage_pct', '>', 85.00, TRUE),
    (1, 'disk_usage_pct', '>', 90.00, TRUE)
ON DUPLICATE KEY UPDATE threshold_id=threshold_id;

-- Muestras iniciales de telemetría histórica
INSERT INTO METRICS (host_id, cpu_usage_pct, ram_used_mb, ram_usage_pct, disk_usage_pct, measured_at)
VALUES 
    (1, 32.50, 19200.00, 58.50, 82.00, NOW() - INTERVAL 1 HOUR),
    (1, 48.00, 19450.00, 59.60, 82.00, NOW() - INTERVAL 45 MINUTE),
    (1, 62.10, 19800.00, 60.00, 82.10, NOW() - INTERVAL 30 MINUTE),
    (1, 84.50, 20600.00, 63.00, 82.20, NOW() - INTERVAL 15 MINUTE),
    (1, 45.20, 19900.00, 61.25, 82.40, NOW());