-- Funcionalidad de aerolinea
-- Secuencia para realizar el autoincrementable
CREATE SEQUENCE aerolinea_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

-- Trigger que se acciona al realizar el insert de aerolinea
CREATE OR REPLACE TRIGGER aerolinea_trigger
BEFORE INSERT ON AEROLINEA
FOR EACH ROW
BEGIN
  :new.ID_AEROLINEA := aerolinea_seq.NEXTVAL; -- Asigna el valor de la secuencia
END;
/

-- Procedimiento para ingresar una aerolinea
CREATE OR REPLACE PROCEDURE PROYECTO2.RegistraAerolinea (
    p_codigo_oaci IN VARCHAR2,
    p_nombre IN VARCHAR2,
    p_ciudad IN VARCHAR2
)
    IS
     v_count NUMBER;
    BEGIN
	    SELECT COUNT(*) INTO v_count
    	FROM AEROLINEA
    	WHERE CODIGO_OACI = p_codigo_oaci;
    	IF v_count > 0 THEN
        	-- Si ya existe, lanza un error
        	RAISE_APPLICATION_ERROR(-20001, 'El CODIGO_OACI ya existe: ' || p_codigo_oaci);
    	ELSE
        	-- Si no existe, inserta la nueva aerolínea
        	INSERT INTO AEROLINEA (CODIGO_OACI, NOMBRE, CIUDAD)
        	VALUES (p_codigo_oaci, p_nombre, p_ciudad);
    	END IF;
        DBMS_OUTPUT.PUT_LINE('Registrado con exito, la aerolinea ' || p_codigo_oaci);
    end;

-- Ejemplo de un insert de aerolinea
BEGIN
    RegistraAerolinea('ASQ', 'Atlantic Southeast Airlines', 'Georgia');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

-- Funcionalidad de Aeropuerto
-- Secuencia para realizar el autoincrementable
CREATE SEQUENCE aeropuertos_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

-- Trigger que se acciona al realizar el insert de aeropuerto
CREATE OR REPLACE TRIGGER trg_aeropuerto_id
BEFORE INSERT ON AEROPUERTO
FOR EACH ROW
BEGIN
    IF :NEW.ID_AEROPUERTO IS NULL THEN
        :NEW.ID_AEROPUERTO := aeropuertos_seq.NEXTVAL;
    END IF;
END;

-- Procedimiento para ingresar un aeropuerto
CREATE OR REPLACE PROCEDURE PROYECTO2.RegistrarAeropuerto (
    p_codigo_iata IN VARCHAR2,
    p_nombre           IN VARCHAR2,
    p_direccion        IN VARCHAR2,
    p_ciudad           IN VARCHAR2,
    p_pista_extendida  IN CHAR,
    p_servicio_aduanero IN CHAR
)
    IS
     v_count NUMBER;
    BEGIN
	    IF p_pista_extendida NOT IN ('0', '1') THEN
        	RAISE_APPLICATION_ERROR(-20001, 'PISTA_EXTENDIDA solo acepta 0 o 1');
    	END IF;

    	-- Validar que SERVICIO_ADUANERO sea '0' o '1'
    	IF p_servicio_aduanero NOT IN ('0', '1') THEN
        	RAISE_APPLICATION_ERROR(-20002, 'SERVICIO_ADUANERO solo acepta 0 o 1');
    	END IF;
    
	    SELECT COUNT(*) INTO v_count
    	FROM AEROPUERTO
    	WHERE CODIGO_IATA = p_codigo_iata;
    	IF v_count > 0 THEN
        	-- Si ya existe, lanza un error
        	RAISE_APPLICATION_ERROR(-20001, 'El CODIGO_IATA ya existe: ' || p_codigo_iata);
    	ELSE
        	-- Si no existe, inserta la nueva aerolínea
        	INSERT INTO AEROPUERTO (CODIGO_IATA, NOMBRE, DIRECCION, CIUDAD, PISTA_EXTENDIDA, SERVICIO_ADUANERO)
        	VALUES (p_codigo_iata, p_nombre, p_direccion, p_ciudad, p_pista_extendida, p_servicio_aduanero);
    	END IF;
        DBMS_OUTPUT.PUT_LINE('Registrado con exito, la aerolinea ' || p_codigo_iata);
    end;

-- Ejemplo de un insert de aeropuerto   
BEGIN
    RegistrarAeropuerto('MAD', 'Aeropuerto Adolfo Suárez Madrid-Barajas', 'Avenida de la Hispanidad, s/n', 'Madrid', '1', '1');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

-- Funcionalidad de puertas de embarque
-- Secuencia para realizar el autoincrementable
CREATE SEQUENCE PUERTAEMBARQUE_SEQ
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE SEQUENCE terminal_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

-- Trigger que se acciona al realizar el insert de puerta de embarque
CREATE OR REPLACE TRIGGER PUERTAEMBARQUE_TRIGGER
BEFORE INSERT ON PUERTAEMBARQUE
FOR EACH ROW
BEGIN
    :NEW.ID_PUERTA := PUERTAEMBARQUE_SEQ.NEXTVAL; -- Asumiendo que PUERTAEMBARQUE_SEQ es tu secuencia
END;

CREATE OR REPLACE TRIGGER trg_terminal_id
BEFORE INSERT ON TERMINAL
FOR EACH ROW
BEGIN
    IF :new.ID_TERMINAL IS NULL THEN
        SELECT terminal_seq.NEXTVAL INTO :new.ID_TERMINAL FROM dual;
    END IF;
END;

-- Procedimiento para ingresar una puerta de embarque
CREATE OR REPLACE PROCEDURE RegistrarPuertasDeEmbarque (
    p_codigo_iata IN VARCHAR2,
    p_terminal IN VARCHAR2,
    p_puertas_embarque IN VARCHAR2
) AS
    v_id_aeropuerto AEROPUERTO.ID_AEROPUERTO%TYPE;
    v_id_terminal TERMINAL.ID_TERMINAL%TYPE;
    v_puerta VARCHAR2(10);
BEGIN
    -- Validar si existe el aeropuerto
    BEGIN
        SELECT ID_AEROPUERTO INTO v_id_aeropuerto
        FROM AEROPUERTO
        WHERE CODIGO_IATA = p_codigo_iata;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        	--DBMS_OUTPUT.PUT_LINE('El aeropuerto con el código IATA ' || p_codigo_iata || ' no existe.');
            RAISE_APPLICATION_ERROR(-20001, 'El aeropuerto con el código IATA ' || p_codigo_iata || ' no existe.');
    END;

    -- Validar si la terminal ya existe asociada al aeropuerto
    BEGIN
        SELECT ID_TERMINAL INTO v_id_terminal
        FROM TERMINAL
        WHERE NOMBRE = p_terminal AND AEROPUERTO_ID_AEROPUERTO = v_id_aeropuerto;

        -- Si la terminal ya existe, continuar con la ejecución
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Si la terminal no existe, insertarla
            INSERT INTO TERMINAL (ID_TERMINAL, NOMBRE, AEROPUERTO_ID_AEROPUERTO)
            VALUES (TERMINAL_SEQ.NEXTVAL, p_terminal, v_id_aeropuerto); -- Asumiendo que TERMINAL_SEQ es la secuencia para ID_TERMINAL
            -- Recuperar el ID de la nueva terminal
            SELECT TERMINAL_SEQ.CURRVAL INTO v_id_terminal FROM DUAL;
    END;

    -- Procesar las puertas de embarque
    FOR puerta IN (SELECT REGEXP_SUBSTR(p_puertas_embarque, '[^,]+', 1, LEVEL) AS PUERTA
                   FROM DUAL
                   CONNECT BY REGEXP_SUBSTR(p_puertas_embarque, '[^,]+', 1, LEVEL) IS NOT NULL) 
    LOOP
        v_puerta := TRIM(puerta.PUERTA);
        BEGIN
            -- Verificar si la puerta ya existe en la terminal
            SELECT 1 INTO v_puerta
            FROM PUERTAEMBARQUE
            WHERE PUERTA = v_puerta AND TERMINAL_ID_TERMINAL = v_id_terminal;

            -- Si la puerta ya existe, lanzar un mensaje
            DBMS_OUTPUT.PUT_LINE('La puerta de embarque ' || v_puerta || ' ya existe en la terminal ' || p_terminal);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Si no existe, insertar la puerta de embarque
                INSERT INTO PUERTAEMBARQUE (PUERTA, TERMINAL_ID_TERMINAL)
                VALUES (v_puerta, v_id_terminal); -- Asumiendo que PUERTAEMBARQUE_SEQ es la secuencia para ID_PUERTA
        END;
    END LOOP;

END RegistrarPuertasDeEmbarque;

-- Ejemplo de un insert de puerta de embarque
BEGIN
    RegistrarPuertasDeEmbarque('MEXs', 'Terminal 3', 'Puerta 5');
END;

-- Funcionalidad de avion
-- Secuencia para realizar el autoincrementable
CREATE SEQUENCE avion_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

-- Trigger que se acciona al realizar el insert de avion
CREATE OR REPLACE TRIGGER AVION_TRIGGER
BEFORE INSERT ON AVION
FOR EACH ROW
BEGIN
    :NEW.ID_AVION := avion_seq.NEXTVAL;
END;

-- Procedimiento para ingresar un avion
CREATE OR REPLACE PROCEDURE Registrar_Avion (
    p_MATRICULA IN VARCHAR2,
    p_MODELO IN VARCHAR2,
    p_CAPACIDAD IN NUMBER,
    p_ESTADO IN VARCHAR2,
    p_ALCANCE IN NUMBER,
    p_ASIENTOS_PRIMERA_CLASE IN NUMBER,
    p_ASIENTOS_SEGUNDA_CLASE IN NUMBER,
    p_ASIENTOS_TERCERA_CLASE IN NUMBER,
    p_AEROLINEA_ID_AEROLINEA IN NUMBER
) IS
    v_count NUMBER;
BEGIN
    -- Validar que la matrícula sea única
    SELECT COUNT(*) INTO v_count
    FROM AVION
    WHERE MATRICULA = p_MATRICULA;
    
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: La matrícula ya existe.');
    END IF;

    -- Validar que la capacidad sea un número positivo
    IF p_CAPACIDAD IS NULL OR p_CAPACIDAD <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: La capacidad debe ser un número positivo.');
    END IF;

    -- Validar que el estado sea '0' o '1'
    IF p_ESTADO NOT IN ('0', '1') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error: El estado debe ser "0" o "1".');
    END IF;

    -- Validar el alcance
    IF p_ALCANCE IS NULL OR p_ALCANCE <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error: El alcance debe ser un número positivo.');
    END IF;

    -- Validar que la aerolínea exista
    SELECT COUNT(*) INTO v_count
    FROM AEROLINEA
    WHERE ID_AEROLINEA = p_AEROLINEA_ID_AEROLINEA;
    
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error: La aerolínea no existe.');
    END IF;

    -- Validar que la suma de asientos sea igual a la capacidad
    IF (p_ASIENTOS_PRIMERA_CLASE + p_ASIENTOS_SEGUNDA_CLASE + p_ASIENTOS_TERCERA_CLASE) <> p_CAPACIDAD THEN
        RAISE_APPLICATION_ERROR(-20006, 'Error: La suma de los asientos debe ser igual a la capacidad.');
    END IF;

    -- Si todas las validaciones pasan, realizar el insert
    INSERT INTO AVION (MATRICULA, MODELO, CAPACIDAD, ESTADO, ALCANCE, ASIENTOS_PRIMERA_CLASE, ASIENTOS_SEGUNDA_CLASE, ASIENTOS_TERCERA_CLASE, AEROLINEA_ID_AEROLINEA)
    VALUES (p_MATRICULA, p_MODELO, p_CAPACIDAD, p_ESTADO, p_ALCANCE, p_ASIENTOS_PRIMERA_CLASE, p_ASIENTOS_SEGUNDA_CLASE, p_ASIENTOS_TERCERA_CLASE, p_AEROLINEA_ID_AEROLINEA);
END;

-- Ejemplo de un insert de avion
BEGIN
    Registrar_Avion(
        'MACH1',
        'Boeing 737',
        180,
        '1',
        3000,
        10,
        80,
        80,
        4
    );
END;