-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS tienda_ropa_online;
USE tienda_ropa_online;

-- Creación de la tabla clientes
CREATE TABLE IF NOT EXISTS clientes (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(100),
    correo_electronico VARCHAR(100) UNIQUE,
    telefono VARCHAR(20)
);

-- Creación de la tabla productos
CREATE TABLE IF NOT EXISTS productos (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    categoria VARCHAR(50),
    stock INT UNSIGNED NOT NULL
);

-- Creación de la tabla pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ID_cliente INT NOT NULL,
    fecha DATE NOT NULL,
    estado VARCHAR(20),
    total DECIMAL(10, 2),
    FOREIGN KEY (ID_cliente) REFERENCES clientes(ID)
);

-- Creación de la tabla ventas
CREATE TABLE IF NOT EXISTS ventas (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ID_pedido INT NOT NULL,
    ID_producto INT NOT NULL,
    cantidad INT UNSIGNED NOT NULL,
    precio_venta DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ID_pedido) REFERENCES pedidos(ID),
    FOREIGN KEY (ID_producto) REFERENCES productos(ID)
);

-- Inserción de datos de ejemplo en la tabla clientes
INSERT INTO clientes (nombre, apellido, direccion, correo_electronico, telefono) VALUES
('Ana', 'Pérez', 'Calle 1 #1-10', 'ana.perez@email.com', '1234567890'),
('Luis', 'González', 'Avenida 2 #20-30', 'luis.gonzalez@email.com', '9876543210'),
('María', 'Rodríguez', 'Carrera 3 #33-33', 'maria.rodriguez@email.com', '5551234567'),
('Carlos', 'López', 'Diagonal 4 #44-40', 'carlos.lopez@email.com', '1112223333'),
('Sofía', 'Martínez', 'Transversal 5 #50-50', 'sofia.martinez@email.com', '4445556666');

-- Inserción de datos de ejemplo en la tabla productos
INSERT INTO productos (nombre, descripcion, precio, categoria, stock) VALUES
('Camiseta Algodón', 'Camiseta básica de algodón', 15.99, 'Camisetas', 100),
('Pantalón Vaquero', 'Pantalón denim clásico', 39.99, 'Pantalones', 50),
('Vestido Verano', 'Vestido ligero para verano', 29.99, 'Vestidos', 75),
('Chaqueta Cuero', 'Chaqueta de piel genuina', 79.99, 'Chaquetas', 30),
('Zapatillas Deportivas', 'Zapatillas para correr', 59.99, 'Calzado', 60);

-- Inserción de datos de ejemplo en la tabla pedidos
INSERT INTO pedidos (ID_cliente, fecha, estado, total) VALUES
(1, '2025-04-15', 'Entregado', 55.97),
(2, '2025-04-20', 'Enviado', 39.99),
(1, '2025-05-01', 'Entregado', 15.99),
(3, '2024-12-10', 'Entregado', 119.98),
(4, '2025-05-05', 'Pendiente', 29.99),
(2, '2025-05-10', 'Entregado', 75.98);

-- Inserción de datos de ejemplo en la tabla ventas
INSERT INTO ventas (ID_pedido, ID_producto, cantidad, precio_venta) VALUES
(1, 1, 2, 15.99),
(1, 3, 1, 23.99),
(2, 2, 1, 39.99),
(3, 1, 1, 15.99),
(4, 2, 1, 39.99),
(4, 4, 1, 79.99),
(5, 3, 1, 29.99),
(6, 1, 1, 15.99),
(6, 3, 2, 29.99);

-- a) Consultas avanzadas con SELECT:

-- Consulta 1: Obtener el nombre completo, dirección y correo electrónico de todos los clientes
-- que han realizado pedidos en los últimos 30 días.
SELECT
    c.nombre,
    c.apellido,
    c.direccion,
    c.correo_electronico
FROM
    clientes c
JOIN
    pedidos p ON c.ID = p.ID_cliente
WHERE
    p.fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY
    c.ID;

-- Consulta 2: Mostrar los productos con mayor cantidad de ventas en el último mes, junto con el
-- total vendido de cada uno.
SELECT
    pr.nombre AS nombre_producto,
    SUM(v.cantidad) AS cantidad_total_vendida,
    SUM(v.cantidad * v.precio_venta) AS total_vendido
FROM
    ventas v
JOIN
    pedidos pe ON v.ID_pedido = pe.ID
JOIN
    productos pr ON v.ID_producto = pr.ID
WHERE
    pe.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY
    pr.ID
ORDER BY
    cantidad_total_vendida DESC;

-- Consulta 3: Listar los clientes que han realizado más pedidos en el último año, ordenados por
-- mayor cantidad de pedidos.
SELECT
    c.nombre,
    c.apellido,
    COUNT(p.ID) AS cantidad_pedidos
FROM
    clientes c
LEFT JOIN
    pedidos p ON c.ID = p.ID_cliente
WHERE
    p.fecha >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY
    c.ID
ORDER BY
    cantidad_pedidos DESC;

-- b) Actualizaciones con UPDATE:

-- Actualización 1: Aumentar el precio de todos los productos de la categoría "Camisetas" en un 10%.
UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Camisetas';

-- c) Eliminaciones con DELETE:

-- Eliminación 2: Eliminar los pedidos que no tengan ventas asociadas.
DELETE FROM pedidos
WHERE ID NOT IN (SELECT DISTINCT ID_pedido FROM ventas);

-- d) Creación de vistas:

-- Vista 1: Crear una vista llamada "vista_clientes_pedidos" que muestre el nombre completo del
-- cliente, la fecha del pedido y el total del pedido.
CREATE VIEW vista_clientes_pedidos AS
SELECT
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo_cliente,
    p.fecha AS fecha_pedido,
    p.total AS total_pedido
FROM
    clientes c
JOIN
    pedidos p ON c.ID = p.ID_cliente;

-- Para consultar la vista creada:
SELECT * FROM vista_clientes_pedidos;
