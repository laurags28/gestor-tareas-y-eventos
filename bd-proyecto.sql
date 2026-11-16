-- ============================================================================
-- PROYECTO: PlanWithMe - Gestor de Tareas, Consultas Médicas y Eventos
-- MOTOR: MySQL / MariaDB (InnoDB)
-- CODIFICACIÓN: utf8mb4_unicode_ci
-- ============================================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+01:00";
SET NAMES utf8mb4;

-- 1. Creación de la base de datos
DROP DATABASE IF EXISTS `planwithme`;
CREATE DATABASE `planwithme`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `planwithme`;

-- ============================================================================
-- 2. ESTRUCTURA DE TABLAS (6 ENTIDADES NORMALIZADAS EN 3FN)
-- ============================================================================

-- Tabla 1: USUARIOS
CREATE TABLE `usuarios` (
  `id_usuario` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `avatar` VARCHAR(255) NOT NULL DEFAULT 'default.png',
  `fecha_registro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuarios_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla 2: CATEGORIAS
CREATE TABLE `categorias` (
  `id_categoria` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `nombre` VARCHAR(50) NOT NULL,
  `color_hex` VARCHAR(7) NOT NULL DEFAULT '#7C3AED',
  `icono` VARCHAR(50) NOT NULL DEFAULT 'tag',
  PRIMARY KEY (`id_categoria`),
  KEY `idx_categorias_usuario` (`id_usuario`),
  CONSTRAINT `fk_categorias_usuario`
    FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla 3: TAREAS
CREATE TABLE `tareas` (
  `id_tarea` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `id_categoria` INT UNSIGNED NULL DEFAULT NULL,
  `titulo` VARCHAR(150) NOT NULL,
  `descripcion` TEXT NULL,
  `prioridad` ENUM('Baja', 'Media', 'Alta') NOT NULL DEFAULT 'Media',
  `fecha_limite` DATE NOT NULL,
  `hora_limite` TIME NULL DEFAULT NULL,
  `completada` TINYINT(1) NOT NULL DEFAULT 0,
  `fecha_completada` DATETIME NULL DEFAULT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_tarea`),
  KEY `idx_tareas_usuario_fecha` (`id_usuario`, `fecha_limite`),
  KEY `idx_tareas_categoria` (`id_categoria`),
  KEY `idx_tareas_completada` (`completada`),
  CONSTRAINT `fk_tareas_usuario`
    FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_tareas_categoria`
    FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla 4: SUBTAREAS
CREATE TABLE `subtareas` (
  `id_subtarea` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_tarea` INT UNSIGNED NOT NULL,
  `titulo` VARCHAR(150) NOT NULL,
  `completada` TINYINT(1) NOT NULL DEFAULT 0,
  `orden` INT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_subtarea`),
  KEY `idx_subtareas_tarea` (`id_tarea`),
  CONSTRAINT `fk_subtareas_tarea`
    FOREIGN KEY (`id_tarea`) REFERENCES `tareas` (`id_tarea`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla 5: EVENTOS (Consultas médicas, citas, reuniones y entregas)
CREATE TABLE `eventos` (
  `id_evento` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `id_categoria` INT UNSIGNED NULL DEFAULT NULL,
  `titulo` VARCHAR(150) NOT NULL,
  `tipo` ENUM('Consulta médica', 'Cita', 'Reunión', 'Entrega') NOT NULL DEFAULT 'Cita',
  `ubicacion` VARCHAR(150) NULL DEFAULT NULL,
  `fecha_evento` DATE NOT NULL,
  `hora_inicio` TIME NOT NULL,
  `hora_fin` TIME NULL DEFAULT NULL,
  `importancia` ENUM('Normal', 'Importante', 'Urgente') NOT NULL DEFAULT 'Normal',
  `notas` TEXT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_evento`),
  KEY `idx_eventos_usuario_fecha` (`id_usuario`, `fecha_evento`),
  KEY `idx_eventos_categoria` (`id_categoria`),
  CONSTRAINT `fk_eventos_usuario`
    FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_eventos_categoria`
    FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla 6: NOTIFICACIONES
CREATE TABLE `notificaciones` (
  `id_notificacion` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `id_tarea` INT UNSIGNED NULL DEFAULT NULL,
  `id_evento` INT UNSIGNED NULL DEFAULT NULL,
  `mensaje` VARCHAR(255) NOT NULL,
  `tipo_aviso` ENUM('Recordatorio', 'Urgencia', 'Sistema') NOT NULL DEFAULT 'Recordatorio',
  `leida` TINYINT(1) NOT NULL DEFAULT 0,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_notificacion`),
  KEY `idx_notificaciones_usuario_leida` (`id_usuario`, `leida`),
  KEY `idx_notificaciones_tarea` (`id_tarea`),
  KEY `idx_notificaciones_evento` (`id_evento`),
  CONSTRAINT `fk_notificaciones_usuario`
    FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_notificaciones_tarea`
    FOREIGN KEY (`id_tarea`) REFERENCES `tareas` (`id_tarea`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_notificaciones_evento`
    FOREIGN KEY (`id_evento`) REFERENCES `eventos` (`id_evento`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;