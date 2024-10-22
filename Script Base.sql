-- Generado por Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   en:        2024-10-21 19:51:57 CST
--   sitio:      Oracle Database 11g
--   tipo:      Oracle Database 11g



DROP TABLE aerolinea CASCADE CONSTRAINTS;

DROP TABLE aeropuerto CASCADE CONSTRAINTS;

DROP TABLE asientos CASCADE CONSTRAINTS;

DROP TABLE avion CASCADE CONSTRAINTS;

DROP TABLE boleto CASCADE CONSTRAINTS;

DROP TABLE cargo CASCADE CONSTRAINTS;

DROP TABLE empleados CASCADE CONSTRAINTS;

DROP TABLE pasajero CASCADE CONSTRAINTS;

DROP TABLE puertaembarque CASCADE CONSTRAINTS;

DROP TABLE reserva CASCADE CONSTRAINTS;

DROP TABLE rutas CASCADE CONSTRAINTS;

DROP TABLE tarifa CASCADE CONSTRAINTS;

DROP TABLE terminal CASCADE CONSTRAINTS;

DROP TABLE tripulacion CASCADE CONSTRAINTS;

DROP TABLE vuelo CASCADE CONSTRAINTS;

-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE aerolinea (
    id_aerolinea INTEGER NOT NULL,
    codigo_oaci  VARCHAR2(10 CHAR) NOT NULL,
    nombre       VARCHAR2(100 CHAR) NOT NULL,
    ciudad       VARCHAR2(50 CHAR) NOT NULL
);

ALTER TABLE aerolinea ADD CONSTRAINT aerolinea_pk PRIMARY KEY ( id_aerolinea );

CREATE TABLE aeropuerto (
    id_aeropuerto     INTEGER NOT NULL,
    codigo_iata       VARCHAR2(10 CHAR) NOT NULL,
    nombre            VARCHAR2(250 CHAR) NOT NULL,
    direccion         VARCHAR2(250 CHAR) NOT NULL,
    ciudad            VARCHAR2(50 CHAR) NOT NULL,
    pista_extendida   CHAR(1) NOT NULL,
    servicio_aduanero CHAR(1) NOT NULL
);

ALTER TABLE aeropuerto ADD CONSTRAINT aeropuerto_pk PRIMARY KEY ( id_aeropuerto );

CREATE TABLE asientos (
    id_asiento     INTEGER NOT NULL,
    numero_asiento VARCHAR2(10 CHAR) NOT NULL,
    clase          VARCHAR2(25 CHAR) NOT NULL,
    avion_id_avion INTEGER NOT NULL
);

ALTER TABLE asientos ADD CONSTRAINT asientos_pk PRIMARY KEY ( id_asiento );

CREATE TABLE avion (
    id_avion               INTEGER NOT NULL,
    matricula              VARCHAR2(15 CHAR) NOT NULL,
    modelo                 VARCHAR2(25 CHAR) NOT NULL,
    capacidad              INTEGER NOT NULL,
    estado                 VARCHAR2(25 CHAR) NOT NULL,
    alcance                INTEGER,
    asientos_primera_clase INTEGER NOT NULL,
    asientos_segunda_clase INTEGER NOT NULL,
    asientos_tercera_clase INTEGER NOT NULL,
    aerolinea_id_aerolinea INTEGER NOT NULL
);

ALTER TABLE avion ADD CONSTRAINT avion_pk PRIMARY KEY ( id_avion );

CREATE TABLE boleto (
    id_boleto                 INTEGER NOT NULL,
    estado                    CHAR(1) NOT NULL,
    pasajero_numero_pasaporte INTEGER NOT NULL,
    vuelo_id_vuelo            INTEGER NOT NULL,
    reserva_id_reserva        INTEGER NOT NULL,
    origen                    VARCHAR2(20 CHAR) NOT NULL,
    asientos_id_asiento       INTEGER NOT NULL,
    empleados_id_empleado     INTEGER NOT NULL
);

ALTER TABLE boleto ADD CONSTRAINT boleto_pk PRIMARY KEY ( id_boleto );

CREATE TABLE cargo (
    id_cargo INTEGER NOT NULL,
    nombre   VARCHAR2(50 CHAR),
    salario  FLOAT(50) NOT NULL
);

ALTER TABLE cargo ADD CONSTRAINT cargo_pk PRIMARY KEY ( id_cargo );

CREATE TABLE empleados (
    id_empleado            INTEGER NOT NULL,
    nombre                 VARCHAR2(100 CHAR) NOT NULL,
    apellido               VARCHAR2(100 CHAR) NOT NULL,
    correo                 VARCHAR2(100 CHAR) NOT NULL,
    telefono               INTEGER NOT NULL,
    direccion              VARCHAR2(100 CHAR) NOT NULL,
    nacimiento             DATE NOT NULL,
    contratado             DATE NOT NULL,
    salario                INTEGER NOT NULL,
    aerolinea_id_aerolinea INTEGER NOT NULL,
    cargo_id_cargo         INTEGER NOT NULL
);

ALTER TABLE empleados ADD CONSTRAINT empleados_pk PRIMARY KEY ( id_empleado );

CREATE TABLE pasajero (
    numero_pasaporte INTEGER NOT NULL,
    nombre           VARCHAR2(100 CHAR) NOT NULL,
    apellido         VARCHAR2(100 CHAR) NOT NULL,
    nacimiento       DATE NOT NULL,
    correo           VARCHAR2(100 CHAR) NOT NULL,
    telefono         INTEGER NOT NULL
);

ALTER TABLE pasajero ADD CONSTRAINT pasajero_pk PRIMARY KEY ( numero_pasaporte );

CREATE TABLE puertaembarque (
    id_puerta            INTEGER NOT NULL,
    puerta               VARCHAR2(10 CHAR) NOT NULL,
    terminal_id_terminal INTEGER NOT NULL
);

ALTER TABLE puertaembarque ADD CONSTRAINT puertaembarque_pk PRIMARY KEY ( id_puerta );

CREATE TABLE reserva (
    id_reserva INTEGER NOT NULL,
    fecha      DATE NOT NULL,
    estado     CHAR(1)
);

ALTER TABLE reserva ADD CONSTRAINT reserva_pk PRIMARY KEY ( id_reserva );

CREATE TABLE rutas (
    id_ruta                   INTEGER NOT NULL,
    tiempo_de_vuelo           INTEGER,
    distancia                 INTEGER,
    aeropuerto_id_aeropuerto  INTEGER NOT NULL,
    aeropuerto_id_aeropuerto1 INTEGER NOT NULL
);

ALTER TABLE rutas ADD CONSTRAINT rutas_pk PRIMARY KEY ( id_ruta );

CREATE TABLE tarifa (
    id_tarifa      INTEGER NOT NULL,
    clase          VARCHAR2(25 CHAR) NOT NULL,
    precio         FLOAT(10) NOT NULL,
    vuelo_id_vuelo INTEGER NOT NULL
);

ALTER TABLE tarifa ADD CONSTRAINT tarifa_pk PRIMARY KEY ( id_tarifa );

CREATE TABLE terminal (
    id_terminal              INTEGER NOT NULL,
    aeropuerto_id_aeropuerto INTEGER NOT NULL,
    nombre                   VARCHAR2(100 CHAR) NOT NULL
);

ALTER TABLE terminal ADD CONSTRAINT terminal_pk PRIMARY KEY ( id_terminal );

CREATE TABLE tripulacion (
    id_tripulacion        INTEGER NOT NULL,
    empleados_id_empleado INTEGER NOT NULL,
    vuelo_id_vuelo        INTEGER NOT NULL
);

ALTER TABLE tripulacion ADD CONSTRAINT tripulacion_pk PRIMARY KEY ( id_tripulacion );

CREATE TABLE vuelo (
    id_vuelo         INTEGER NOT NULL,
    fecha_salida     DATE NOT NULL,
    fecha_llegada    DATE NOT NULL,
    estado           VARCHAR2(25 CHAR) NOT NULL,
    tarifa_primera   FLOAT NOT NULL,
    tarifa_ejecutiva FLOAT NOT NULL,
    tarifa_economica FLOAT NOT NULL,
    ruta             CHAR(1) NOT NULL,
    rutas_id_ruta    INTEGER NOT NULL,
    avion_id_avion   INTEGER NOT NULL
);

ALTER TABLE vuelo ADD CONSTRAINT vuelo_pk PRIMARY KEY ( id_vuelo );

ALTER TABLE asientos
    ADD CONSTRAINT asientos_avion_fk FOREIGN KEY ( avion_id_avion )
        REFERENCES avion ( id_avion );

ALTER TABLE avion
    ADD CONSTRAINT avion_aerolinea_fk FOREIGN KEY ( aerolinea_id_aerolinea )
        REFERENCES aerolinea ( id_aerolinea );

ALTER TABLE boleto
    ADD CONSTRAINT boleto_asientos_fk FOREIGN KEY ( asientos_id_asiento )
        REFERENCES asientos ( id_asiento );

ALTER TABLE boleto
    ADD CONSTRAINT boleto_empleados_fk FOREIGN KEY ( empleados_id_empleado )
        REFERENCES empleados ( id_empleado );

ALTER TABLE boleto
    ADD CONSTRAINT boleto_pasajero_fk FOREIGN KEY ( pasajero_numero_pasaporte )
        REFERENCES pasajero ( numero_pasaporte );

ALTER TABLE boleto
    ADD CONSTRAINT boleto_reserva_fk FOREIGN KEY ( reserva_id_reserva )
        REFERENCES reserva ( id_reserva );

ALTER TABLE boleto
    ADD CONSTRAINT boleto_vuelo_fk FOREIGN KEY ( vuelo_id_vuelo )
        REFERENCES vuelo ( id_vuelo );

ALTER TABLE empleados
    ADD CONSTRAINT empleados_aerolinea_fk FOREIGN KEY ( aerolinea_id_aerolinea )
        REFERENCES aerolinea ( id_aerolinea );

ALTER TABLE empleados
    ADD CONSTRAINT empleados_cargo_fk FOREIGN KEY ( cargo_id_cargo )
        REFERENCES cargo ( id_cargo );

ALTER TABLE puertaembarque
    ADD CONSTRAINT puertaembarque_terminal_fk FOREIGN KEY ( terminal_id_terminal )
        REFERENCES terminal ( id_terminal );

ALTER TABLE rutas
    ADD CONSTRAINT rutas_aeropuerto_fk FOREIGN KEY ( aeropuerto_id_aeropuerto )
        REFERENCES aeropuerto ( id_aeropuerto );

ALTER TABLE rutas
    ADD CONSTRAINT rutas_aeropuerto_fkv1 FOREIGN KEY ( aeropuerto_id_aeropuerto1 )
        REFERENCES aeropuerto ( id_aeropuerto );

ALTER TABLE tarifa
    ADD CONSTRAINT tarifa_vuelo_fk FOREIGN KEY ( vuelo_id_vuelo )
        REFERENCES vuelo ( id_vuelo );

ALTER TABLE terminal
    ADD CONSTRAINT terminal_aeropuerto_fk FOREIGN KEY ( aeropuerto_id_aeropuerto )
        REFERENCES aeropuerto ( id_aeropuerto );

ALTER TABLE tripulacion
    ADD CONSTRAINT tripulacion_empleados_fk FOREIGN KEY ( empleados_id_empleado )
        REFERENCES empleados ( id_empleado );

ALTER TABLE tripulacion
    ADD CONSTRAINT tripulacion_vuelo_fk FOREIGN KEY ( vuelo_id_vuelo )
        REFERENCES vuelo ( id_vuelo );

ALTER TABLE vuelo
    ADD CONSTRAINT vuelo_avion_fk FOREIGN KEY ( avion_id_avion )
        REFERENCES avion ( id_avion );

ALTER TABLE vuelo
    ADD CONSTRAINT vuelo_rutas_fk FOREIGN KEY ( rutas_id_ruta )
        REFERENCES rutas ( id_ruta );

CREATE SEQUENCE aerolinea_id_aerolinea_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER aerolinea_id_aerolinea_trg BEFORE
    INSERT ON aerolinea
    FOR EACH ROW
    WHEN ( new.id_aerolinea IS NULL )
BEGIN
    :new.id_aerolinea := aerolinea_id_aerolinea_seq.nextval;
END;
/

CREATE SEQUENCE aeropuerto_id_aeropuerto_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER aeropuerto_id_aeropuerto_trg BEFORE
    INSERT ON aeropuerto
    FOR EACH ROW
    WHEN ( new.id_aeropuerto IS NULL )
BEGIN
    :new.id_aeropuerto := aeropuerto_id_aeropuerto_seq.nextval;
END;
/

CREATE SEQUENCE asientos_id_asiento_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER asientos_id_asiento_trg BEFORE
    INSERT ON asientos
    FOR EACH ROW
    WHEN ( new.id_asiento IS NULL )
BEGIN
    :new.id_asiento := asientos_id_asiento_seq.nextval;
END;
/

CREATE SEQUENCE avion_id_avion_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER avion_id_avion_trg BEFORE
    INSERT ON avion
    FOR EACH ROW
    WHEN ( new.id_avion IS NULL )
BEGIN
    :new.id_avion := avion_id_avion_seq.nextval;
END;
/

CREATE SEQUENCE boleto_id_boleto_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER boleto_id_boleto_trg BEFORE
    INSERT ON boleto
    FOR EACH ROW
    WHEN ( new.id_boleto IS NULL )
BEGIN
    :new.id_boleto := boleto_id_boleto_seq.nextval;
END;
/

CREATE SEQUENCE cargo_id_cargo_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER cargo_id_cargo_trg BEFORE
    INSERT ON cargo
    FOR EACH ROW
    WHEN ( new.id_cargo IS NULL )
BEGIN
    :new.id_cargo := cargo_id_cargo_seq.nextval;
END;
/

CREATE SEQUENCE puertaembarque_id_puerta_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER puertaembarque_id_puerta_trg BEFORE
    INSERT ON puertaembarque
    FOR EACH ROW
    WHEN ( new.id_puerta IS NULL )
BEGIN
    :new.id_puerta := puertaembarque_id_puerta_seq.nextval;
END;
/

CREATE SEQUENCE reserva_id_reserva_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER reserva_id_reserva_trg BEFORE
    INSERT ON reserva
    FOR EACH ROW
    WHEN ( new.id_reserva IS NULL )
BEGIN
    :new.id_reserva := reserva_id_reserva_seq.nextval;
END;
/

CREATE SEQUENCE rutas_id_ruta_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER rutas_id_ruta_trg BEFORE
    INSERT ON rutas
    FOR EACH ROW
    WHEN ( new.id_ruta IS NULL )
BEGIN
    :new.id_ruta := rutas_id_ruta_seq.nextval;
END;
/

CREATE SEQUENCE tarifa_id_tarifa_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tarifa_id_tarifa_trg BEFORE
    INSERT ON tarifa
    FOR EACH ROW
    WHEN ( new.id_tarifa IS NULL )
BEGIN
    :new.id_tarifa := tarifa_id_tarifa_seq.nextval;
END;
/

CREATE SEQUENCE terminal_id_terminal_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER terminal_id_terminal_trg BEFORE
    INSERT ON terminal
    FOR EACH ROW
    WHEN ( new.id_terminal IS NULL )
BEGIN
    :new.id_terminal := terminal_id_terminal_seq.nextval;
END;
/

CREATE SEQUENCE tripulacion_id_tripulacion_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tripulacion_id_tripulacion_trg BEFORE
    INSERT ON tripulacion
    FOR EACH ROW
    WHEN ( new.id_tripulacion IS NULL )
BEGIN
    :new.id_tripulacion := tripulacion_id_tripulacion_seq.nextval;
END;
/



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            15
-- CREATE INDEX                             0
-- ALTER TABLE                             33
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                          12
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                         12
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
