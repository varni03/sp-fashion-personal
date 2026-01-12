-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    login TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    cart JSONB DEFAULT '{}'::jsonb,
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    in_stock BOOLEAN DEFAULT TRUE,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    size TEXT,  -- e.g. 'S', 'M', 'L', 'XL'
    colors TEXT[] DEFAULT ARRAY[]::TEXT[], -- multiple colors, e.g. {'red','blue','black'}
    invoice TEXT,
    paid BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- Orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    delivered BOOLEAN DEFAULT FALSE,
    shipped BOOLEAN DEFAULT FALSE,
    shipping_label TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments table
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    type TEXT CHECK (type IN ('credit_card','paypal','bank_transfer')),
    receipt TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Images table
CREATE TABLE images (
    img_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id) ON DELETE CASCADE,
    url TEXT NOT NULL
);
