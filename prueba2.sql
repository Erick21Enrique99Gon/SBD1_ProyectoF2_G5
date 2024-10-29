CREATE OR REPLACE PROCEDURE CompradeBoleto (
    Vuelo IN NUMBER,
    Asiento IN NUMBER,
    Empleado IN NUMBER,
    Pasajero IN NUMBER,
    Reserva IN NUMBER
)
IS
    nuevoId NUMBER;
    asientoDisponible INT;
    vueloExiste INT;
    pasajeroExiste INT;
    reservaExiste INT;
    fechaActual DATE;
    empleadoCargo VARCHAR2(50);
BEGIN
    -- Obtener la fecha actual del sistema
    SELECT SYSDATE INTO fechaActual FROM DUAL;

    -- Validar que el vuelo exista
    SELECT COUNT(*) INTO vueloExiste FROM VUELO WHERE ID_VUELO = Vuelo;
    IF vueloExiste = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: El vuelo no existe.');
    END IF;

    -- Validar que el asiento esté disponible
    SELECT COUNT(*) INTO asientoDisponible
    FROM BOLETO
    WHERE VUELO_ID_VUELO = Vuelo AND ASIENTOS_ID_ASIENTO = Asiento;
    
    IF asientoDisponible > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: El asiento ya está ocupado.');
    END IF;

    -- Si la reserva es 0, el boleto se trata como adquirido desde ventanilla
    IF Reserva = 0 THEN
        empleadoCargo := 'ventanilla';
    ELSE
        -- Validar que el empleado exista y obtener su cargo
        SELECT C.NOMBRE INTO empleadoCargo
        FROM EMPLEADOS E
        JOIN CARGO C ON E.CARGO_ID_CARGO = C.ID_CARGO
        WHERE E.ID_EMPLEADO = Empleado;
    END IF;

    -- Validar que el pasajero exista
    SELECT COUNT(*) INTO pasajeroExiste FROM PASAJERO WHERE NUMERO_PASAPORTE = Pasajero;
    IF pasajeroExiste = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error: El pasajero no existe.');
    END IF;

    -- Validar que la reserva exista (si es distinta de 0)
    IF Reserva != 0 THEN
        SELECT COUNT(*) INTO reservaExiste FROM RESERVA WHERE ID_RESERVA = Reserva;
        IF reservaExiste = 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Error: La reserva no existe.');
        END IF;
    END IF;

    -- Insertar el nuevo boleto
    INSERT INTO BOLETO (ID_BOLETO, ESTADO, PASAJERO_NUMERO_PASAPORTE, VUELO_ID_VUELO, RESERVA_ID_RESERVA, ORIGEN, ASIENTOS_ID_ASIENTO, EMPLEADOS_ID_EMPLEADO)
    VALUES (1, 'A', Pasajero, Vuelo, Reserva, 'ORIGEN', Asiento, Empleado);

    DBMS_OUTPUT.PUT_LINE('Boleto insertado correctamente con fecha: ' || TO_CHAR(fechaActual, 'DD/MM/YYYY'));
END;
