CREATE USER payment_rw WITH PASSWORD 'P@ss99W0rd' SUPERUSER;
CREATE DATABASE payment_dev WITH OWNER payment_rw ENCODING 'utf8' LC_COLLATE = 'en_US.UTF-8'; 