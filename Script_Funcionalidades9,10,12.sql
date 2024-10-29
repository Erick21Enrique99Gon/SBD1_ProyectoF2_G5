CREATE OR REPLACE PROCEDURE AsignarTripulacion (
    CodigoEmpleado IN NUMBER,
    CodigoVuelo IN NUMBER
)
IS
    nuevoIdTripulacion NUMBER;
    TotalPilotos INT;
    TotalServicio INT;
    CargoEmpleado VARCHAR2(50); -- Ajusta el tamaño según tu base de datos
    FechaVuelo DATE;
    v_count INT;
BEGIN
    -- Obtener un nuevo ID para la tripulación usando la secuencia
    SELECT SEQ_TRIPULACION_ID.NEXTVAL INTO nuevoIdTripulacion FROM DUAL;

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

    -- Contar pilotos y empleados de servicio asignados al vuelo
    SELECT COUNT(*) INTO TotalPilotos 
    FROM TRIPULACION T, EMPLEADOS E, CARGO C
    WHERE T.EMPLEADOS_ID_EMPLEADO = E.ID_EMPLEADO
    AND E.CARGO_ID_CARGO = C.ID_CARGO
    AND T.VUELO_ID_VUELO = CodigoVuelo 
    AND (C.NOMBRE = 'Piloto' OR C.NOMBRE = 'Copiloto');

    SELECT COUNT(*) INTO TotalServicio 
    FROM TRIPULACION T, EMPLEADOS E, CARGO C
    WHERE T.EMPLEADOS_ID_EMPLEADO = E.ID_EMPLEADO
    AND E.CARGO_ID_CARGO = C.ID_CARGO
    AND T.VUELO_ID_VUELO = CodigoVuelo 
    AND C.NOMBRE = 'Servidor';

    -- Generar advertencias en lugar de errores
    IF TotalPilotos < 2 THEN
        DBMS_OUTPUT.PUT_LINE('Advertencia: Se recomienda tener al menos 2 pilotos asignados.');
    END IF;
    IF TotalServicio < 3 THEN
        DBMS_OUTPUT.PUT_LINE('Advertencia: Se recomienda tener al menos 3 empleados de servicio asignados.');
    END IF;

    -- Asignar al empleado a la tripulación del vuelo
    INSERT INTO TRIPULACION (ID_TRIPULACION, EMPLEADOS_ID_EMPLEADO, VUELO_ID_VUELO) 
    VALUES (nuevoIdTripulacion, CodigoEmpleado, CodigoVuelo);

    DBMS_OUTPUT.PUT_LINE('Empleado asignado exitosamente a la tripulación del vuelo.');
END;











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

    -- Obtener un nuevo ID para BOLETO usando una secuencia
    SELECT SEQ_BOLETO_ID.NEXTVAL INTO nuevoId FROM DUAL;

    -- Insertar el nuevo boleto
    INSERT INTO BOLETO (
        ID_BOLETO, ESTADO, PASAJERO_NUMERO_PASAPORTE, VUELO_ID_VUELO, RESERVA_ID_RESERVA, ORIGEN, ASIENTOS_ID_ASIENTO, EMPLEADOS_ID_EMPLEADO
    ) VALUES (
        nuevoId, 1, Pasajero, Vuelo, Reserva, 'ORIGEN', Asiento, Empleado
    );

    DBMS_OUTPUT.PUT_LINE('Boleto insertado correctamente con fecha: ' || TO_CHAR(fechaActual, 'DD/MM/YYYY'));
END;







CREATE OR REPLACE PROCEDURE CancelarReservacion (
    IdReserva IN NUMBER
)
IS
    reservaExiste INT;
    reservaCancelada INT;
BEGIN
    -- Validar que la reserva exista
    SELECT COUNT(*) INTO reservaExiste FROM RESERVA WHERE ID_RESERVA = IdReserva;
    IF reservaExiste = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: La reserva no existe.');
    END IF;

    -- Validar que la reserva no haya sido cancelada previamente
    SELECT ESTADO INTO reservaCancelada FROM RESERVA WHERE ID_RESERVA = IdReserva;
    IF reservaCancelada = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: La reserva ya fue cancelada antes.');
    END IF;

    -- Actualizar el estado de la reserva a '0' (Cancelada)
    UPDATE RESERVA 
    SET ESTADO = 0
    WHERE ID_RESERVA = IdReserva;

    -- Actualizar el estado de los boletos asociados a la reserva a '0' (Cancelado)
    UPDATE BOLETO 
    SET ESTADO = 0
    WHERE RESERVA_ID_RESERVA = IdReserva;

    -- Liberar los asientos asociados a la reserva
    UPDATE ASIENTOS 
    SET ESTADO = 0
    WHERE ID_ASIENTO IN (
        SELECT ASIENTOS_ID_ASIENTO 
        FROM BOLETO 
        WHERE RESERVA_ID_RESERVA = IdReserva
    );

    DBMS_OUTPUT.PUT_LINE('Reservación cancelada y asientos liberados correctamente.');
END;






