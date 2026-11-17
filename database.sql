-- Blodato CMS - Eksiksiz Veritabanı Şeması (Güncel Versiyon)

CREATE DATABASE IF NOT EXISTS blodato CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE blodato;

-- 1. Ayarlar Tablosu
CREATE TABLE IF NOT EXISTS settings (
    setting_key VARCHAR(50) PRIMARY KEY,
    setting_value TEXT
) ENGINE=InnoDB;

-- 2. Kullanıcılar Tablosu (Roller ve Profil Özellikleri Dahil)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'editor', 'author') DEFAULT 'author',
    bio TEXT,
    profile_pic VARCHAR(255) DEFAULT 'assets/img/default-avatar.png',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Yazılar Tablosu
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    content LONGTEXT,
    category VARCHAR(50),
    status ENUM('draft', 'published') DEFAULT 'draft',
    lang ENUM('tr', 'en') DEFAULT 'tr',
    author_id INT,
    allow_comments TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 4. Sayfalar Tablosu (Hakkımızda vb.)
CREATE TABLE IF NOT EXISTS pages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    content LONGTEXT,
    status ENUM('draft', 'published') DEFAULT 'published',
    lang ENUM('tr', 'en') DEFAULT 'tr',
    author_id INT,
    allow_comments TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 5. Yorumlar Tablosu (Editor Onay İstek Sistemi Dahil)
CREATE TABLE IF NOT EXISTS comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    author_name VARCHAR(100) NOT NULL,
    author_email VARCHAR(100),
    content TEXT NOT NULL,
    status ENUM('pending', 'approved', 'spam') DEFAULT 'pending',
    editor_request VARCHAR(20) DEFAULT NULL, -- 'approve', 'delete', 'spam' istekleri için
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. İstatistikler/Ziyaretler Tablosu
CREATE TABLE IF NOT EXISTS visits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    page_url VARCHAR(255),
    visit_date DATE,
    visit_count INT DEFAULT 1,
    UNIQUE KEY unique_visit (page_url, visit_date)
) ENGINE=InnoDB;

-- --- BAŞLANGIÇ VERİLERİ ---

-- Varsayılan Ayarlar
INSERT INTO settings (setting_key, setting_value) VALUES 
('site_title', 'Blodato CMS'),
('site_slogan', 'Modern ve Özgür Yayıncılık'),
('hero_text', 'Blodato ile İçeriklerinizi Özgürce Paylaşın'),
('primary_button_text', 'Yazıları Gör'),
('primary_button_url', '/'),
('secondary_button_text', 'Hakkımızda'),
('secondary_button_url', '/page.php?slug=hakkimizda'),
('social_links', '{"github": "", "email": "", "twitter": ""}'),
('menu_links', '[{"label":"Anasayfa","url":"/"}]'),
('accent_color', '#1a1a27'),
('border_radius', '20px'),
('maintenance_mode', '0'),
('global_comments', '1'),
('show_author_bio', '1'),
('site_logo', 'assets/img/logo.png'),
('site_favicon', 'assets/img/logo.png')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);

-- Varsayılan Admin Kullanıcısı (Kullanıcı adı: admin, Şifre: admin123)
INSERT INTO users (username, password, role, bio) VALUES 
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'Sistem Yöneticisi')
ON DUPLICATE KEY UPDATE role = 'admin';
