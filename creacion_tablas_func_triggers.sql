-----------------------------------------------------------------
----------------------------TABLAS-------------------------------
-----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS materias (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(25),
  horas_semanales INTEGER
);

CREATE TABLE IF NOT EXISTS sexos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(1)
);

CREATE TABLE IF NOT EXISTS profesores (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(30),
  apellido VARCHAR(30),
  fec_nac DATE,
  domic_calle VARCHAR(40),
  domic_numero integer,
  sexos_id integer,
  FOREIGN KEY (sexos_id) REFERENCES sexos(id)
);

CREATE TABLE profesores_has_materias(
    profesores_id INTEGER,
    materias_id INTEGER,
    UNIQUE(profesores_id,materias_id),
    FOREIGN KEY (profesores_id) REFERENCES profesores(id),
    FOREIGN KEY (materias_id) REFERENCES materias(id)
);

CREATE TABLE IF NOT EXISTS alumnos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(30),
  apellido VARCHAR(30),
  fec_nac date,
  domic_calle VARCHAR(40),
  domic_numero integer,
  sexos_id integer,
  examenes_id integer,
  FOREIGN KEY (sexos_id) REFERENCES sexos(id)
);


CREATE TABLE examenes(
    id SERIAL PRIMARY KEY,
    fecha date,
    calificacion NUMERIC(4,2),
    profesores_has_materias_profesores_id INTEGER NOT NULL,
    profesores_has_materias_materias_id INTEGER NOT NULL,
    alumnos_id integer not null,
    FOREIGN KEY (profesores_has_materias_profesores_id, profesores_has_materias_materias_id)
    REFERENCES profesores_has_materias(profesores_id, materias_id),
    FOREIGN KEY (alumnos_id) REFERENCES alumnos(id)
);

CREATE TABLE alumnos_has_materias(
    alumnos_id INTEGER,
    materias_id INTEGER,
    UNIQUE(alumnos_id,materias_id),
    FOREIGN KEY (alumnos_id) REFERENCES alumnos(id),
    FOREIGN KEY (materias_id) REFERENCES materias(id)
);

-----------------------------------------------------------------
----------------------------FUNCIONES----------------------------
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_obtener_promedio(id_alumno integer)
RETURNS numeric(4,2) language plpgsql as $$
declare
    promedio numeric(4,2);
BEGIN
    select avg(e.calificacion)
    into promedio
    from alumnos a
    join examenes e on a.id = e.alumnos_id
    where alumnos_id = id_alumno;

    return promedio;
END;
$$;

CREATE OR REPLACE FUNCTION f_verificar_anio_nac()
RETURNS TRIGGER language plpgsql as $$
declare
    anio_nac integer;
BEGIN
    anio_nac := extract(year from new.fec_nac);

    if anio_nac < 2008 or anio_nac > 2017 then
        raise exception 'La fecha de nacimiento debe estar entre 2008 y 2017';
    end if;
    return new;
END;
$$;

CREATE OR REPLACE FUNCTION f_verificar_calificacion()
RETURNS TRIGGER language plpgsql as $$
BEGIN
    if new.calificacion < 0 or new.calificacion > 10 then
        raise exception 'La calificación debe estar entre 0 y 10';
    end if;
    return new;
END;
$$;

-----------------------------------------------------------------
----------------------------TRIGGERS-----------------------------
-----------------------------------------------------------------
CREATE OR REPLACE TRIGGER tr_verificar_anio_nac
BEFORE INSERT
on alumnos
for each ROW
execute function f_verificar_anio_nac();

INSERT INTO alumnos(nombre, apellido, fec_nac, domic_calle, domic_numero, sexos_id)
VALUES('Alejandro', 'Luna', '2019-06-18', 'Corrientes', 5303, 1);

CREATE OR REPLACE TRIGGER tr_verificar_calificacion
BEFORE INSERT
on examenes
for each ROW
execute function f_verificar_calificacion();

INSERT INTO examenes(fecha, calificacion, profesores_has_materias_profesores_id, profesores_has_materias_materias_id, alumnos_id)
VALUES('2022-05-04', 5, 1, 1, 1);


-----------------------------------------------------------------
---------------------------VISTAS--------------------------------
-----------------------------------------------------------------
create view listado_alumnos as select apellido, nombre, fec_nac from alumnos order by apellido, nombre;
create view info_examenes as select e.id, e.fecha, e.calificacion,
       a.apellido apellido_alumno, a.nombre nombre_alumno
from examenes e
join alumnos a
on e.alumnos_id = a.id
order by calificacion desc;

