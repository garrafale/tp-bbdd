-- 1) Obtener lista de materias ordenadas por mayor carga horaria. Crear vista llamada "Horas por Asignatura"
create view horas_por_asignatura as select nombre, horas_semanales from materias order by horas_semanales desc;
select * from horas_por_asignatura;

/* 2) Obtener listín de alumnos en orden alfabético. Mostrar los siguientes datos:
- Nombre y apellido en formato -> "Apellido, Nombre"
- Fecha de cumpleaños -> dd/MM */
select apellido || ', ' || nombre as nombre_completo,
to_char(fec_nac, 'DD/MM') as fecha_cumpleaños
from alumnos order by apellido, nombre;

/*3) Mostrar la cantidad de alumnos de cada sexo que hay en cada materia, ordenada alfabéticamente.
Se debe mostrar el resultado en esta forma, por ejemplo:
Materia     |   M   |   F
Matemática  |   12  |   15
Biología    |   20  |   11 */
select m.nombre materia,
       COUNT(case when s.nombre = 'M' then a.id end) M,
       COUNT(case when s.nombre = 'F' then a.id end) F
from alumnos a
join sexos s on a.sexos_id = s.id
join alumnos_has_materias ahm on a.id = ahm.alumnos_id
join materias m on ahm.materias_id = m.id
group by m.nombre order by m.nombre;

/*4) Mostrar la tasa de aprobación por cada profesor. La tasa de aprobación es la relación entre 
exámenes aprobados y desaprobados.
Mostrar:
- Apellido y nombre del docente (en una misma columna) bajo el nombre "Profesor"
- Tasa de aprobación con signo % al final. */
select p.apellido || ', ' || p.nombre profesor,
       COUNT(distinct case when e.calificacion >= 6 then e.id end) total_aprobados,
       COUNT(distinct e.id) total_examenes,
       round((COUNT(case when e.calificacion >= 6 then e.id end) * 100.00 / COUNT(e.id)),2) || '%' tasa_aprobacion
from profesores p
join profesores_has_materias phm on p.id = phm.profesores_id
join examenes e on phm.profesores_id = e.profesores_has_materias_profesores_id
group by p.id;

/*5) Crear función para ver promedios de notas de los alumnos. Deben aparecer ordenados por alumno.
Mostrar (con el nombre de la columna especificado entre comillas):

/*6) Crear query para mostrar el promedio detallado de notas de un alumno. Agrupar las notas por trimestre.
Para ello usar función `extract(quarter from fecha_examen)` donde fecha_examen es el nombre de la columna*/
select a.apellido || ', ' || a.nombre alumno,
    EXTRACT(QUARTER from e.fecha) trimestre,
    ROUND(AVG(e.calificacion), 2) promedio
from alumnos a join examenes e on a.id = e.alumnos_id
where a.id = 1
group by a.apellido, a.nombre, EXTRACT(QUARTER from e.fecha)
order by a.apellido, a.nombre, trimestre;


/*7) Mostrar la cantidad total de examenes realizada por cada profesor y por cada materia.
Ordenar por cantidad y materia.
Ordenar por cantidad de exámenes realizados.*/
select 
    p.apellido || ' ' || p.nombre profesor,
    m.nombre materia,
    COUNT(e.id) cantidad_examenes
from profesores p
join profesores_has_materias phm on p.id = phm.profesores_id
join examenes e on phm.profesores_id = e.profesores_has_materias_profesores_id 
     and phm.materias_id = e.profesores_has_materias_materias_id
join materias m on phm.materias_id = m.id
group by p.apellido, p.nombre, m.nombre
order by COUNT(e.id) desc, m.nombre;



/*8) Para elegir los abanderados del acto del 9 de Julio, se pide obtener a los mejores promedios. Son 3 banderas en total y 3 alumnos
por cada una de ellas. Importante: no mostrar más alumnos que la cantidad necesaria.
Se pide mostrar una lista de:
- Apellido y nombre del alumno
- Domicilio (calle - número)
- Nota promedio redondeado a 1 decimal.
Mostrando primero el promedio más alto y luego los demás.*/
select a.id, a.apellido, a.nombre, a.domic_calle, a.domic_numero, round(avg(e.calificacion),1) promedio from alumnos a
join examenes e on a.id = e.alumnos_id
where extract(month from e.fecha) < 7 or (extract(month from e.fecha) = 7 and extract(day from e.fecha) < 9)
group by a.id
order by round(avg(e.calificacion),2) desc
fetch first 9 rows only;

--9. Determinar cuántas materias cursa el alumno más joven del colegio (mostrar quién es y su fecha de nacimiento):
select a.apellido, a.nombre, count(*) cantidad, a.fec_nac from alumnos a
join alumnos_has_materias ahm on a.id = ahm.alumnos_id
join materias m on ahm.materias_id = m.id
group by a.id
order by a.fec_nac desc
fetch first 1 rows only;

--10. Determinar cuántas horas semanales de clase da el profesor de ID = 4 (mostrar id, nombre y apellido), sumando todas las materias que enseña:
select p.id, p.apellido, p.nombre, sum(m.horas_semanales)horas_totales from profesores p
join profesores_has_materias phm on p.id = phm.profesores_id
join materias m on phm.materias_id = m.id
where p.id = 4
group by p.id;