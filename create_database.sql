CREATE DATABASE restaurantsDW; 

USE restaurantsDW; 

CREATE TABLE dimFecha(
    FechaID varchar(30) NOT NULL PRIMARY KEY,
    Fecha DATE NOT NULL,
    NumeroMes INT NOT NULL,
    NombreMes VARCHAR(15) NOT NULL,
    NumeroDiaSemana INT NOT NULL,
    NombreDiaSemana VARCHAR(15) NOT NULL,
    Anio SMALLINT NOT NULL,
    Periodo VARCHAR(30) NOT NULL
);



CREATE TABLE dimCliente(
    ClienteID INT NOT NULL PRIMARY KEY, 
    Cliente VARCHAR(100) NOT NULL, 
    Sexo char(1) NOT NULL,
    Ciudad VARCHAR(50) NOT NULL,
    PresupuestoMensual MONEY NOT NULL
);

CREATE TABLE dimPlato(
    PlatoID INT NOT NULL PRIMARY KEY, 
    Plato VARCHAR(50) NOT NULL,
    TipoServicio VARCHAR(50) NOT NULL, 
    TipoPlato VARCHAR(50) NOT NULL,
    CalienteFrio VARCHAR(50) NOT NULL,
    Precio MONEY
);


CREATE TABLE dimRestaurante(
    RestauranteID INT NOT NULL PRIMARY KEY, 
    Restaurante VARCHAR(50) NOT NULL, 
    TipoRestaurante VARCHAR(50) NOT NULL,
    Ciudad VARCHAR(50) NOT NULL 
);

CREATE TABLE dimIngrediente(
    IngredienteID INT NOT NULL PRIMARY KEY, 
    Ingrediente VARCHAR(50) NOT NULL
)

CREATE TABLE factOrdenIngredientes(
    ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    OrdenID INT NOT NULL,
    FechaID VARCHAR(30) NOT NULL FOREIGN KEY REFERENCES dimFecha(FechaID),
    ClienteID INT NOT NULL FOREIGN KEY REFERENCES dimCliente(ClienteID),
    RestauranteID INT NOT NULL FOREIGN KEY REFERENCES dimRestaurante(RestauranteID),
    PlatoID INT NOT NULL FOREIGN KEY REFERENCES dimPlato(PlatoID),
    IngredienteID INT NOT NULL FOREIGN KEY REFERENCES dimIngrediente(IngredienteID),
    CantidadIngrediente INT NOT NULL
);

CREATE TABLE factOrden(
    ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    OrdenID INT NOT NULL,
    FechaID VARCHAR(30) NOT NULL FOREIGN KEY REFERENCES dimFecha(FechaID),
    ClienteID INT NOT NULL FOREIGN KEY REFERENCES dimCliente(ClienteID),
    RestauranteID INT NOT NULL FOREIGN KEY REFERENCES dimRestaurante(RestauranteID),
    PlatoID INT NOT NULL FOREIGN KEY REFERENCES dimPlato(PlatoID),
    PrecioPlato MONEY NOT NULL, 
)

CREATE TABLE factGastoCliente(
    ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    OrdenID INT NOT NULL,
    FechaID VARCHAR(30) NOT NULL FOREIGN KEY REFERENCES dimFecha(FechaID),
    ClienteID INT NOT NULL FOREIGN KEY REFERENCES dimCliente(ClienteID),
    RestauranteID INT NOT NULL FOREIGN KEY REFERENCES dimRestaurante(RestauranteID),
    Total MONEY NOT NULL, 
    NumeroComidas INT NOT NULL,
    PromedioComida MONEY NOT NULL
)

