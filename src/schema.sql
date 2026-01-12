-- E-commerce Database Schema for PostgreSQL

-- Create database (run this separately if needed)
-- CREATE DATABASE ecommerce;

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    login VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- Should store hashed passwords
    cart JSONB DEFAULT '[]', -- Store cart items as JSON array
    preferences JSONB DEFAULT '{}', -- Store user preferences as JSON object
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    in_stock INTEGER DEFAULT 0,
    price DECIMAL(10, 2) NOT NULL,
    size VARCHAR(20),
    color VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    delivered BOOLEAN DEFAULT FALSE,
    shipped BOOLEAN DEFAULT FALSE,
    shipping_label VARCHAR(255),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivered_date TIMESTAMP,
    shipped_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Order items table (to handle many-to-many relationship between orders and products)
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

-- Payments table
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    received BOOLEAN DEFAULT FALSE,
    payment_type VARCHAR(50) NOT NULL, -- 'credit_card', 'paypal', 'bank_transfer', etc.
    receipt VARCHAR(255), -- Receipt number or file path
    transaction_id VARCHAR(255) UNIQUE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Images table
CREATE TABLE images (
    img_id SERIAL PRIMARY KEY,
    product_id INTEGER,
    file_path VARCHAR(500) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Invoices table (separate from products as suggested by your schema)
CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    issued_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date TIMESTAMP,
    paid BOOLEAN DEFAULT FALSE,
    paid_date TIMESTAMP,
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_users_login ON users(login);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_images_product_id ON images(product_id);
CREATE INDEX idx_invoices_order_id ON invoices(order_id);
CREATE INDEX idx_products_price ON products(price);

-- Create triggers to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample data insertion (optional)
-- INSERT INTO users (login, password) VALUES 
-- ('john_doe', '$2a$10$example_hashed_password'),
-- ('jane_smith', '$2a$10$another_hashed_password');

-- INSERT INTO products (name, description, in_stock, price, size, color) VALUES
-- ('T-Shirt', 'Cotton t-shirt', 50, 19.99, 'M', 'Blue'),
-- ('Jeans', 'Denim jeans', 30, 49.99, '32', 'Black'),
-- ('Sneakers', 'Running shoes', 25, 79.99, '10', 'White');

-- View to get order details with payment status
CREATE VIEW order_summary AS
SELECT 
    o.id as order_id,
    u.login as customer,
    o.total_amount,
    o.delivered,
    o.shipped,
    p.received as payment_received,
    p.payment_type,
    i.paid as invoice_paid,
    o.order_date
FROM orders o
JOIN users u ON o.user_id = u.id
LEFT JOIN payments p ON o.id = p.order_id
LEFT JOIN invoices i ON o.id = i.order_id;
