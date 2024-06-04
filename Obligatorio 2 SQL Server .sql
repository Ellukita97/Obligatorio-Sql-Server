create database gastronomia;

use gastronomia;

/*Creación Tablas*/

CREATE TABLE AMIGOS(
idAmigo int primary key,
tipoAmigo varchar(10) check(tipoAmigo in('Encargados', 'Cocineros','Otros')) not null,
nomAmigo varchar(30) not null,
telefAmigo varchar(20) ,
mailAmigo varchar(30) not null
)

CREATE TABLE RESTAURANTES(
idRest int primary key,
nomRest varchar(30) unique,
paisRest varchar(30),
dirRest varchar(50),
telefRest varchar(20) not null,
idAmigo int not null references AMIGOS(idAmigo)
)

CREATE TABLE COCINEROS(
experiencia int,
idAmigo int primary key not null references AMIGOS(idAmigo),
idRest int not null references RESTAURANTES(idRest)
)

CREATE TABLE RECETAS(
idReceta int identity(1,1) primary key,
idAmigoCoc int not null references COCINEROS(idAmigo),
nomReceta varchar(100) not null,
linkReceta varchar(300) not null unique,
tipoReceta varchar(10) check(tipoReceta in( 'postre', 'aperitivo', 'entrada', 'ppal', 'Otros' )) not null,
fechaReg date not null,
cantVisitas int not null,
fchUltVisita date not null
)
CREATE TABLE PLATOS(
idRest int not null references RESTAURANTES(idRest),
nomPlato varchar(100) not null,
idReceta int not null references RECETAS(idReceta),
enCarta char(2) check(enCarta in( 'SI','NO')),
precio numeric(12,2),
primary key(idRest, nomPlato),
unique(idRest, nomPlato)
)

CREATE TABLE RECETASEVALUACIONES(
idReceta int not null references RECETAS(idReceta),
fechaEval date not null,
fechaDesde date not null,
fechaHasta date not null,
califReceta int check(califReceta > 0 and califReceta < 6) not null,
esLaMejor bit not null,
primary key(idReceta , fechaEval)
)

CREATE TABLE AMIGOSCALIF_RECETAS(
idAmigo int not null references AMIGOS(idAmigo) ,
fecha date not null,
idReceta int not null references RECETAS(idReceta),
estrellas int check(estrellas > 0 and estrellas < 6),
primary key(idAmigo, fecha, idReceta)
)

CREATE TABLE AMIGOSCALIF_PLATOS(
idAmigo int not null references AMIGOS(idAmigo),
fecha date not null,
idRest int not null references RESTAURANTES(idRest ),
nomPlato varchar(100) not null,
estrellas int not null,
primary key(idAmigo, fecha, idRest, nomPlato)
)

CREATE TABLE SORTEOSGANADORES(
idSorteo int identity(1,1) primary key,
fechaSorteo date not null,
idAmigo int not null references AMIGOS(idAmigo),
idRest int not null references RESTAURANTES(idRest)
)


/*Ejercicios:*/

/*5.a*/

select *
from RECETASEVALUACIONES inner join RECETAS
on RECETASEVALUACIONES.idReceta = RECETAS.idReceta 
inner join PLATOS
on PLATOS.idReceta = RECETAS.idReceta
inner join RESTAURANTES
on RESTAURANTES.idRest = PLATOS.idRest
where RECETASEVALUACIONES.califReceta > 3
	and RECETASEVALUACIONES.fechaEval > '2023/01/01' 
	and RECETAS.idReceta not in(select PLATOS.idReceta
								from PLATOS inner join RESTAURANTES
								on PLATOS.idRest = RESTAURANTES.idRest
								and RESTAURANTES.paisRest = 'Uruguay')


/*5.b*/

select nomPlato
from PLATOS inner join RESTAURANTES
on PLATOS.idRest = RESTAURANTES.idRest
where RESTAURANTES.nomRest = 'RUFFINO' 
and PLATOS.nomPlato in (select AMIGOSCALIF_PLATOS.nomPlato
						from AMIGOSCALIF_PLATOS
						GROUP BY AMIGOSCALIF_PLATOS.nomPlato
						HAVING COUNT(*) >= 5 and MIN(AMIGOSCALIF_PLATOS.estrellas) >= 3
						) 
												

/*5.c*/

select r.idAmigoCoc, COUNT(r.idAmigoCoc) AS CantRecetas, MAX(r.fechaReg) AS primerRecetaCreada,  MIN(r.fechaReg) AS ultimaRecetaCreada, MAX(ar.fecha) AS UltimaReview
from RECETAS r inner join AMIGOSCALIF_RECETAS ar
on r.idReceta = ar.idReceta
GROUP BY r.idAmigoCoc




/*5.d*/

select r.nomReceta ,r.cantVisitas
from RECETAS r

/*5.e*/

select r.nomReceta ,COUNT(r.tipoReceta) AS CantTipoReceta, MAX(ar.estrellas) AS MaxReviewTipoReceta
from RECETAS r inner join AMIGOSCALIF_RECETAS ar
on r.idReceta = ar.idReceta
GROUP BY r.nomReceta

/*6.a*/

CREATE or ALTER PROCEDURE IdRecetaPromedioEstrellas
@idReceta int
AS
BEGIN
 
SELECT AVG(AMIGOSCALIF_RECETAS.estrellas)  FROM AMIGOSCALIF_RECETAS WHERE AMIGOSCALIF_RECETAS.idReceta = @idReceta;

END
 
execute IdRecetaPromedioEstrellas 1

/*6.b*/

CREATE or ALTER PROCEDURE RecetasRegMesAnio 
@mes varchar(2),
@anio varchar(4)
AS
BEGIN
 
SELECT RECETAS.fechaReg  FROM RECETAS WHERE YEAR(RECETAS.fechaReg) = @anio and MONTH(RECETAS.fechaReg) = @mes;

END
 
execute RecetasRegMesAnio @mes ='05' , @anio = '2008' 







/*6.c*/
CREATE or ALTER PROCEDURE NomTelAmigoGanadorSorteo  
AS
BEGIN
 
SELECT AMIGOS.nomAmigo,AMIGOS.telefAmigo  
FROM AMIGOS inner join SORTEOSGANADORES 
on  AMIGOS.idAmigo = SORTEOSGANADORES.idAmigo
where YEAR(SORTEOSGANADORES.fechaSorteo) = YEAR(GETDATE());

END
 
execute NomTelAmigoGanadorSorteo  

/*6.d*/
create or alter function PlatoServidoEnRestaurantes
(
@nomPlato varchar(100)
)
returns varchar(100)
AS
BEGIN
return(SELECT /*PLATOS.nomPlato,*/ RESTAURANTES.nomRest 
FROM PLATOS inner join RESTAURANTES
on PLATOS.idRest = RESTAURANTES.idRest
WHERE PLATOS.nomPlato = @nomPlato);
END

/*7 TRIGGERS*/

/*tabla: RECETASEVALUACIONES*/

--1
CREATE OR ALTER TRIGGER fechaDesdeNoMenorAFechaHasta
on RECETASEVALUACIONES 
AFTER INSERT
AS
begin
	if((select inserted.fechaDesde from inserted)>(select inserted.fechaHasta from inserted))
	begin
		raiserror ('FechaDesde no puede ser mayor que fechaHasta',16, 1)
		ROLLBACK TRANSACTION
	end
end

/*tabla: AMIGOSCALIF_RECETAS*/

--1
CREATE OR ALTER TRIGGER responsablesNoCalificanRecetasQueEsténPlatosSusRestaurantes
on AMIGOSCALIF_RECETAS
AFTER INSERT
as
declare @idAmigo int= null
declare @idReceta int = null
declare @a int= null
declare @b int = null
begin

	select @idAmigo = inserted.idAmigo, @idReceta = inserted.idReceta
	from inserted

	select @a = RESTAURANTES.idAmigo, @b = PLATOS.idReceta
	from RESTAURANTES inner join PLATOS
	on RESTAURANTES.idRest = PLATOS.idRest
	inner join RECETAS
	on PLATOS.idReceta = RECETAS.idReceta
	where @idAmigo = RESTAURANTES.idAmigo and @idReceta = PLATOS.idReceta

	if(@a = @idAmigo and @b = @idReceta)
	begin
		raiserror ('responsables de restaurantes no pueden calificar recetas que estén en platos de sus restaurantes.',16, 1)
		print @idAmigo    
		print @idReceta
		print @a
		print @b 
		ROLLBACK TRANSACTION
	end
	else
	begin
		print @idAmigo    
		print @idReceta
		print @a
		print @b 
	end
end






--2

Create or alter trigger a
on AMIGOSCALIF_RECETAS
after insert
as
declare @Anio int
declare @Amigo int
declare @Receta int
declare @cantFecha int
begin

	select @Amigo = idAmigo, @Receta = idReceta  from inserted
	
	select @Anio = year(fecha)
	from AMIGOSCALIF_RECETAS
	where @Amigo = AMIGOSCALIF_RECETAS.idAmigo
	
	select @cantFecha = Count(year(fecha))
	from AMIGOSCALIF_RECETAS
where  AMIGOSCALIF_RECETAS.idAmigo = @Amigo
	group by year(fecha)

	if(@cantFecha > 1 )
	begin
		raiserror ('Nadie puede calificar una receta si ya la califico en el último año',16, 1)
		print @Amigo
		print @cantFecha
		ROLLBACK TRANSACTION
	end
	if
	(@Receta in(
			select idReceta /* , AMIGOSCALIF_PLATOS.nomPlato, idAmigo*/  
			from PLATOS inner join AMIGOSCALIF_PLATOS
			on PLATOS.nomPlato = AMIGOSCALIF_PLATOS.nomPlato
			where @Amigo = idAmigo
		))
	begin
		raiserror ('Has calificado un plato de esta receta.',16, 1)
		ROLLBACK TRANSACTION
	end
end






--3
CREATE OR ALTER TRIGGER CocineroAutorNoCalificarSusRecetas
on AMIGOSCALIF_RECETAS
after insert
as
declare @RecetaAmigo int
declare @idAmigo int
begin

	select @idAmigo = inserted.idAmigo
	from inserted

	select @RecetaAmigo = inserted.idReceta from inserted

	if(@RecetaAmigo in (select idReceta from RECETAS where @idAmigo = RECETAS.idAmigoCoc))
	begin
		raiserror ('Cocineros no pueden calificar recetas de las que es autor.',16, 1)
		print @idAmigo
		print @RecetaAmigo
		ROLLBACK TRANSACTION
	end
end

/*tabla: AMIGOSCALIF_PLATOS */

--1

create or alter trigger AmigoCalifEnPlatos
on AMIGOSCALIF_PLATOS
after insert
as
begin
	declare @PLatoname varchar(100)

	select @PLatoname = ap.nomPlato
	from AMIGOSCALIF_PLATOS ap 

	if(@PLatoname not in (select nomPlato from PLATOS))
	begin
		raiserror ('Nombre del plato no existe',16, 1)
		ROLLBACK TRANSACTION
	end
end




/*tabla: COCINEROS */

--1

create or alter trigger AmigoEsCoinero
on COCINEROS
after insert
as
begin
	declare @TipoAmigo varchar(100)

	select @TipoAmigo = tipoAmigo from AMIGOS a inner join inserted i
	on a.idAmigo = i.idAmigo

	if(@TipoAmigo <> 'Cocineros')
	begin
		raiserror ('El amigo no es un cocinero',16, 1)
		ROLLBACK TRANSACTION
	end
end

