CREATE OR REPLACE PROCEDURE AsignarTripulacion (
    ID_Tripulacion IN NUMBER,
    CodigoEmpleado IN NUMBER,
    CodigoVuelo IN NUMBER
)
IS
    TotalPilotos INT;
    TotalServicio INT;
    CargoEmpleado VARCHAR2(50); -- Ajusta el tamaño según tu base de datos
    FechaVuelo DATE;
    v_count INT;
BEGIN
    -- Validar que el vuelo exista
    SELECT COUNT(*) INTO v_count FROM VUELO WHERE ID_VUELO = CodigoVuelo;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: El vuelo no existe. Código de vuelo: ' || CodigoVuelo);
    END IF;

    -- Validar que el empleado exista
    SELECT COUNT(*) INTO v_count FROM EMPLEADOS WHERE ID_EMPLEADO = CodigoEmpleado;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: El empleado no existe. Código de empleado: ' || CodigoEmpleado);
    END IF;

    -- Obtener la descripción del cargo del empleado
    SELECT NOMBRE INTO CargoEmpleado
    FROM CARGO
    WHERE ID_CARGO = (SELECT CARGO_ID_CARGO FROM EMPLEADOS WHERE ID_EMPLEADO = CodigoEmpleado);

    -- Verificar si el cargo es "ventanilla"
    IF CargoEmpleado = 'ventanilla' THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error: El cargo de ventanilla no está permitido para tripulación. Código de empleado: ' || CodigoEmpleado);
    END IF;

    -- Obtener la fecha del vuelo
    SELECT FECHA_SALIDA INTO FechaVuelo FROM VUELO WHERE ID_VUELO = CodigoVuelo;

    -- Validar disponibilidad del empleado en la fecha del vuelo
    SELECT COUNT(*) INTO v_count 
    FROM TRIPULACION T, VUELO V
    WHERE T.VUELO_ID_VUELO = V.ID_VUELO 
    AND T.EMPLEADOS_ID_EMPLEADO = CodigoEmpleado 
    AND V.FECHA_SALIDA = FechaVuelo;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error: El empleado ya está asignado a otro vuelo en esta fecha.');
    END IF;

    -- Asignar al empleado a la tripulación del vuelo con el nuevo ID_Tripulacion
    INSERT INTO TRIPULACION (ID_TRIPULACION, EMPLEADOS_ID_EMPLEADO, VUELO_ID_VUELO) 
    VALUES (ID_Tripulacion, CodigoEmpleado, CodigoVuelo);

    -- -- Contar pilotos y empleados de servicio asignados al vuelo
    -- SELECT COUNT(*) INTO TotalPilotos 
    -- FROM TRIPULACION T, EMPLEADOS E, CARGO C
    -- WHERE T.EMPLEADOS_ID_EMPLEADO = E.ID_EMPLEADO
    -- AND E.CARGO_ID_CARGO = C.ID_CARGO
    -- AND T.VUELO_ID_VUELO = CodigoVuelo 
    -- AND (C.NOMBRE = 'Piloto' OR C.NOMBRE = 'Copiloto');

    -- SELECT COUNT(*) INTO TotalServicio 
    -- FROM TRIPULACION T, EMPLEADOS E, CARGO C
    -- WHERE T.EMPLEADOS_ID_EMPLEADO = E.ID_EMPLEADO
    -- AND E.CARGO_ID_CARGO = C.ID_CARGO
    -- AND T.VUELO_ID_VUELO = CodigoVuelo 
    -- AND C.NOMBRE = 'Servidor';

    -- -- Validar mínimo de tripulación después de la asignación
    -- IF TotalPilotos < 2 THEN
    --     RAISE_APPLICATION_ERROR(-20005, 'Error: Se requieren al menos 2 pilotos.');
    -- END IF;
    -- IF TotalServicio < 3 THEN
    --     RAISE_APPLICATION_ERROR(-20006, 'Error: Se requieren al menos 3 empleados de servicio.');
    -- END IF;

    DBMS_OUTPUT.PUT_LINE('Empleado asignado exitosamente a la tripulación del vuelo.');
END;
/













CREATE OR REPLACE PROCEDURE CompraDeBoleto(
    Fecha DATE,
    Vuelo NUMBER,
    Asiento NUMBER,
    Empleado NUMBER,
    Pasajero NUMBER,
    Reserva NUMBER
)
IS
    v_count INT;
    estado_asiento CHAR(1);
BEGIN
    -- Validar que el vuelo exista y que no haya partido
    SELECT COUNT(*) INTO v_count FROM VUELO WHERE ID_VUELO = Vuelo AND FECHA_SALIDA > SYSDATE;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: El vuelo no existe o ya ha partido.');
    END IF;

    -- Validar que el asiento esté disponible
    SELECT ESTADO INTO estado_asiento FROM ASIENTOS WHERE ID_ASIENTO = Asiento;
    IF estado_asiento != 'D' THEN -- 'D' para Disponible
        RAISE_APPLICATION_ERROR(-20002, 'Error: El asiento no está disponible.');
    END IF;

    -- Validar que el empleado sea de ventanilla
    SELECT COUNT(*) INTO v_count FROM EMPLEADOS WHERE ID_EMPLEADO = Empleado AND CARGO_ID_CARGO = (SELECT ID_CARGO FROM CARGO WHERE NOMBRE = 'Ventanilla');
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error: El empleado no es de ventanilla.');
    END IF;

    -- Validar que el pasajero exista
    SELECT COUNT(*) INTO v_count FROM PASAJERO WHERE NUMERO_PASAPORTE = Pasajero;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error: El pasajero no existe.');
    END IF;

    -- Validar que la reserva exista si el número de reserva no es 0
    IF Reserva != 0 THEN
        SELECT COUNT(*) INTO v_count FROM RESERVA WHERE ID_RESERVA = Reserva;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Error: La reserva no existe.');
        END IF;
    END IF;

    -- Insertar el boleto
    INSERT INTO BOLETO (ID_BOLETO, ESTADO, PASAJERO_NUMERO_PASAPORTE, VUELO_ID_VUELO, RESERVA_ID_RESERVA, ORIGEN, ASIENTOS_ID_ASIENTO, EMPLEADOS_ID_EMPLEADO)
    VALUES (SEQ_BOLETO.NEXTVAL, 'A', Pasajero, Vuelo, Reserva, 'Origen', Asiento, Empleado);

    DBMS_OUTPUT.PUT_LINE('Boleto insertado correctamente.');
END;
