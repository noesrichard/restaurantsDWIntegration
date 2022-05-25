
DELETE FROM factOrden; 
DELETE FROM factOrdenIngredientes; 
DELETE FROM dimCliente; 
DELETE FROM dimFecha; 
DELETE FROM dimIngrediente; 
DELETE FROM dimPlato; 
DELETE FROM dimRestaurante; 

----------------------------------------------------------------------------------------------------
---------------------------------Poblado de datos
----------------------------------------------------------------------------------------------------

-- dimRestaurante
SELECT id, r.restaurant_name, rt.restaurant_type, c.city
FROM dbo.restaurants r, dbo.restaurant_types rt, dbo.cities c
WHERE r.restaurant_type_id = rt.id AND (r.city_id = c.id)

-- dimCliente
SELECT c.id as ClienteID, c.monthly_budget as PresupuestoMensual, c.first_name + ' ' + surname as name, c.sex, ct.city
FROM  costumers c,  dbo.cities ct
WHERE c.city_id = ct.id

-- dimPlato
SELECT m.id as PlatoID, m.meal_name, mt.meal_type, st.serve_type, m.hot_cold, m.price
FROM meals m, meal_types mt, serve_types st
WHERE m.serve_type_id = st.id and m.meal_type_id = mt.id

-- dimFechas
declare @datecursor CURSOR; 
declare @f datetime;
declare @anio int;
declare @mes varchar(15); 
declare @dia varchar(15); 
declare @periodo varchar(30);
declare @periodocorto char(1);
declare @idfecha varchar(50); 
set dateformat dmy; 

begin 
    set @datecursor = CURSOR FOR
    select dateadd(hour, datepart(hour, o.hour), o.date)
    from restaurants.dbo.orders o;

    open @datecursor
    fetch next from @datecursor
    into @f
    
    while @@fetch_status = 0 begin
        set @periodo = case
                            when datepart(hour, @f) >= 5 and datepart(hour, @f) < 12
                            then 'Mañana'
                            when datepart(hour, @f) >= 12 and datepart(hour, @f) < 18
                            then 'Mediodia/Tarde'
                            else 'Noche'
                        end

        set @periodocorto = case when @periodo = 'Mañana' then 'M' when @periodo = 'Mediodia/Tarde' then 'T' else 'N' end 

        set @idfecha = CAST(YEAR(@f)*10000+MONTH(@f)*100+DAY(@f) as varchar(15))+@periodocorto;
        set @anio = YEAR(@f);
        set @mes = case 
                        when DATEPART(MONTH, @f) = 1 then 'Enero'
                        when DATEPART(MONTH, @f) = 2 then 'Febrero'
                        when DATEPART(MONTH, @f) = 3 then 'Marzo'
                        when DATEPART(MONTH, @f) = 4 then 'Abril'
                        when DATEPART(MONTH, @f) = 5 then 'Mayo'
                        when DATEPART(MONTH, @f) = 6 then 'Junio'
                        when DATEPART(MONTH, @f) = 7 then 'Julio'
                        when DATEPART(MONTH, @f) = 8 then 'Agosto'
                        when DATEPART(MONTH, @f) = 9 then 'Septiembre'
                        when DATEPART(MONTH, @f) = 10 then 'Octubre'
                        when DATEPART(MONTH, @f) = 11 then 'Noviembre'
                        else 'Diciembre'
                    end;
        set @dia = case 
                        when DATEPART(WEEKDAY, @f) = 1 then 'Lunes'
                        when DATEPART(WEEKDAY, @f) = 2 then 'Martes'
                        when DATEPART(WEEKDAY, @f) = 3 then 'Miercoles'
                        when DATEPART(WEEKDAY, @f) = 4 then 'Jueves'
                        when DATEPART(WEEKDAY, @f) = 5 then 'Viernes'
                        when DATEPART(WEEKDAY, @f) = 6 then 'Sabado'
                        when DATEPART(WEEKDAY, @f) = 7 then 'Domingo'
                    end;

        if not exists( SELECT FechaID from restaurantsDW.dbo.dimFecha where FechaID = @idfecha ) begin 

            insert into restaurantsDW.dbo.dimFecha(FechaID, Fecha, NumeroMes, NombreMes, NumeroDiaSemana, NombreDiaSemana, Anio, Periodo) 
            values(@idfecha, @f, DATEPART(MONTH, @f), @mes, DATEPART(DAY, @f), @dia, @anio, @periodo); 
        end;
        fetch next from @datecursor
        into @f
    end; 
    close @datecursor;
    deallocate @datecursor; 
end; 

-- factOrden
SELECT 
     orders.id as OrdenID
    ,orders.costumer_id as ClienteID
    ,orders.restaurant_id as RestauranteID
    ,orders_details.meal_id as PlatoID
    ,meals.price as PrecioPlato
	,CAST(YEAR(orders.date)*10000+MONTH(orders.date)*100+DAY(orders.date) as varchar(50)) as Fecha
	,datepart(hour, dateadd(hour, datepart(hour, orders.hour), orders.date)) as Hora
FROM 
	restaurants.dbo.orders as orders,
    restaurants.dbo.order_details as orders_details,
    restaurants.dbo.meals as meals
WHERE 
	orders.id = orders_details.order_id
	and orders_details.meal_id = meals.id 

-- factOrdenIngredientes
SELECT 
     orders.id as OrdenID
    ,orders.costumer_id as ClienteID
    ,orders.restaurant_id as RestauranteID
    ,orders_details.meal_id as PlatoID
	,meals_ingredients.ingredient_id as IngredienteID
	,meals_ingredients.quantity as CantidadIngrediente
	,CAST(YEAR(orders.date)*10000+MONTH(orders.date)*100+DAY(orders.date) as varchar(50)) as Fecha
	,datepart(hour, dateadd(hour, datepart(hour, orders.hour), orders.date)) as Hora
FROM 
	restaurants.dbo.orders as orders,
    restaurants.dbo.order_details as orders_details,
    restaurants.dbo.meals as meals, 
	restaurants.dbo.meal_ingredients as meals_ingredients
WHERE 
	orders.id = orders_details.order_id
	and orders_details.meal_id = meals.id 
	and meals.id = meals_ingredients.meal_id

-- factGastoCliente
SELECT 
     orders.id as OrdenID
    ,orders.costumer_id as ClienteID
    ,orders.restaurant_id as RestauranteID
    ,orders.total_order as Total
	,( SELECT COUNT(order_details.meal_id) 
		FROM restaurants.dbo.order_details as order_details
		WHERE orders.id = order_details.order_id) as NumeroComidas
	,CAST(YEAR(orders.date)*10000+MONTH(orders.date)*100+DAY(orders.date) as varchar(50)) as Fecha
	,datepart(hour, dateadd(hour, datepart(hour, orders.hour), orders.date)) as Hora
FROM 
	restaurants.dbo.orders as orders
WHERE orders.total_order != 0

	

