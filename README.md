# Obligatorio-Sql-Server

Proyecto Obligatorio de SQL Server de la materia Bases de Datos 2

## Introducción

El proyecto consiste en la creación de la base de datos de una red de restaurantes, esta tiene un sistema de "amigos" los cuales tienen la capacidad de puntuar platos creados por los "cocineros", tanto los encargados como los cocineros creadores de una receta no pueden calificarla.

## Base de datos

https://github.com/Ellukita97/Obligatorio-Sql-Server/blob/main/Obligatorio%202%20SQL%20Server%20.sql

## Informe

Se realizaron las creaciones de las tablas y sus restricciones en base a sus necesidades. 
Los tipos de la tabla amigos deben ser "Encargados", "Cocineros" o "Otros".

En la tabla restaurantes se aplicaron restricciones en el teléfono haciéndolo requerido realizando un not null y el responsable del restaurante es un amigo por lo tanto va a ser una referencia a la tabla amigos.

Los cocineros son amigos de tipo cocinero. Para realizar esto creamos un trigger que compruebe si el amigo iniciado es de tipo cocinero y en el caso de la experiencia no se le aplicó ninguna restricción ya que puede ser null.

En el caso de los platos  los nombres deben de ser de hasta 100 caracteres, para eso usamos el tipo varchar(100) siendo 100 el máximo de caracteres ingresados en la variable, el nombre del plato puede repetirse en distintos restaurantes pero no en el mismo, para esto se realizó una restricción unique haciendo que el restaurante y nombre del plato sean únicos

La tabla recetas se identifican con un autonumérico, el link de la misma no se repite por un unique, la fecha de registro no puede ser posterior a la actual por lo tanto se creó una restricción que check,
en el caso de tipo reseta el campo solo puede tomar valores: postre, aperitivo, entrada, ppal, otro.

En la tabla recetas evaluaciones se realiza una restricción not null en todos los campos ya que todos los campos son requeridos y se creó un trigger para comprobar que la fechaDesde es siempre menor a la fechaHasta.

La tabla AMIGOSCALIF_RECETAS contiene un campo llamado estrellas que solo puede ser un número del 1 al 5, para esto se realizó un check que indique que es mayor a 0 y menor a 6, se realiza una restricción not null en todos los campos ya que todos los campos son requeridos.

Se realiza un trigger porque los responsables de restaurantes no pueden calificar recetas que estén en platos de sus restaurantes, para esto comprueba si la receta está en las recetas creadas del amigo que se insertó y si es cierto realiza un error.

Otro trigger es necesario porque los cocineros no pueden calificar recetas de las que es autor, para la realización de esto comprueba si la receta insertada está en las recetas creadas por el cocinero

Y como último trigger se comprueba que nadie pueda calificar una receta si ya la calificó en el último año o calificó un plato de esa receta. para realizar esto realizamos una selección al año de la receta insertada, agrupamos los años de las fechas calificadas del amigo para comprobar que no aya años repetidos porque si lo hay significa que ya calificó en ese año por lo tanto la calificación no se inserta, y en el caso de que el año sea diferente comprueba si el amigo calificó en algún plato y si es cierto tampoco se inserta la calificación.

En el caso de la tabla AMIGOSCALIF_PLATOS el campo llamado estrellas solo puede ser un número del 1 al 5 por lo tanto se realiza el check,  se realiza una restricción not null en todos los campos ya que todos los campos son requeridos.

Para esta tabla se realizó un trigger que compruebe si el nombre del plato ingresado esta en los platos existentes, para esto seleccionamos el nombre del plato y comprobamos de que este en el nombre de los platos

La última tabla creada es la tabla SORTEOSGANADORES  a la cuál se realiza una restricción not null en todos los campos ya que todos los campos son requeridos.

## Digrama de base de datos
![Image](https://raw.githubusercontent.com/Ellukita97/Obligatorio-Sql-Server/main/SQL%20Server.png)


