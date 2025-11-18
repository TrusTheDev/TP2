
Program BitMarket;
uses SysUtils, unix;
const 
 MAX = 500;
Type
tFecha = Record
  dia: Integer;
  mes: Integer;
  anio: Integer
end;
tRegNegocio = Record
  Seccion: String;
  Codigo: String;
  Nombre: String;
  Stock: Integer;
  Precio: real;
  FechaAdq: tFecha;
  FechaUv: tFecha;
  FechaCad: tFecha;
  alta: boolean
end;
ArrSecciones = Array [1..MAX] of string;
tArchNegocio = File of tRegNegocio;
tArchText = Text;
ArrRegNegocio = Array [1..MAX] of tRegNegocio;

procedure cadenAfecha(var Fecha: tFecha; aux: String);
(* Que hace: Recibe una cadena de fecha en formato DD/MM/YYYY y devuelve un tipo tfecha
  Precondiciones: aux = A; aux con formato: DD/MM/YYYY.
  Poscondiciones: Fecha = F';  Fecha perteneciente al tipo tFecha.
*)
var
 i: Integer;
 strNumber: String;
 caracterAux: char;
 barraInvertida: Integer;
begin
  barraInvertida := 0;
  i := 1;     
    while barraInvertida <= 2 do
    begin
        caracterAux := 'A';
        strNumber := '';
        while (caracterAux <> '/') and (i <= Length(aux)) do
        begin
            caracterAux := aux[i];
            if caracterAux <> '/' then
                strNumber := concat(strNumber,caracterAux);
            i := i + 1
        end;
        case barraInvertida of
          0: Fecha.dia := StrToInt(strNumber);
          1: Fecha.mes := StrToInt(strNumber);
          2: Fecha.anio := StrToInt(strNumber);
        end;
        barraInvertida := barraInvertida + 1;  
    end;
end;
    
function cadenAlogico(aux: String):boolean;
(*  Que hace: verifica si un caracter es 'S'
    precondicones: aux = A
    poscondiciones: cadenAlogico = V o cadenAlogico = F
*)
begin
    cadenAlogico := aux = 'S';
end;

procedure cadenaAregistro(var Negocio: tRegNegocio; cadReg: String);
(*  Que hace: convierte una cadena dada separada por , con cada valor a un tRegNegocio.
    precondicones: cadReg = C cadReg mantiene el orden 'Seccion,Codigo,Nombre,Stock,Precio,DD/MM/YYYY,DD/MM/YYYY,DD/MM/YYYY,alta'
    poscondiciones: Negocio = N perteneciente al tipo tRegNegocio
*)
var
  i: Integer;
  aux: String;
  comas: Integer;
begin
  aux := '';
  comas := 0;
  for i:=1 to Length(cadReg) do
  begin
    if (cadReg[i] = ',') or (i = Length(cadReg)) then
      begin
        comas := comas + 1;
        case comas of
          1: Negocio.Seccion := aux;
          2: Negocio.Codigo := aux; 
          3: Negocio.Nombre := aux;
          4: Negocio.Stock := StrToInt(aux);
          5: Negocio.Precio := StrToFloat(aux);
          6: cadenAfecha(Negocio.FechaAdq, aux);
          7: cadenAfecha(Negocio.FechaUv, aux);
          8: cadenAfecha(Negocio.FechaCad, aux);
          9: Negocio.alta := cadenAlogico(aux);
        end;
        aux := '';
      end
    else
    begin
      aux := aux + cadReg[i];  
    end;
  end;
end;

function contadorLineasArchivo(FilePath: String): Integer;
(*  Que hace: cuenta la cantidad de lineas de un archivo.
    precondicones: FilePath = F y el directorio debe existir y tener texto.
    poscondiciones: contadorLineasArchivo = n
*)
var
  textoArchivo: tArchText;
  contadorLineas: Integer;
  tempS: String;
begin
  Assign(textoArchivo, FilePath);
  Reset(textoArchivo);
  contadorLineas := 0;
  while not EoF(textoArchivo) do
  begin
    ReadLn(textoArchivo, tempS);
    contadorLineas := contadorLineas + 1;
  end;
  close(textoArchivo);
  contadorLineasArchivo := contadorLineas;
end;

function lineasArchivoNegocio(FilePath: String): Integer;
(*  Que hace: cuenta la cantidad de lineas de un archivo de tRegNegocio.
    precondicones: FilePath = F y el directorio debe existir y debe ser de tRegNegocio.
    poscondiciones: contadorLineasArchivo = n
*)
var
  textoArchivo: tArchNegocio;
  contadorLineas: Integer;
  tempS: tRegNegocio;
begin
  Assign(textoArchivo, FilePath);
  Reset(textoArchivo);
  contadorLineas := 0;
  while not EoF(textoArchivo) do
  begin
    Read(textoArchivo, tempS);
    contadorLineas := contadorLineas + 1;
  end;
  close(textoArchivo);
  lineasArchivoNegocio := contadorLineas;
end;

Procedure lineArchivo(var tempVar2: String; Indice: Integer; RelativePath: String);
(*  Que hace: obtiene una linea dado de un archivo de texto por el indice.
    precondicones: Indice = I, RelativePath = R el archivo debe existir y Indice >= 0, el archivo debe ser de texto.
    poscondiciones: tempVar2 = T
*)
Var
  archivoLinea: tArchText;
  i: Integer;
Begin
  Assign(archivoLinea, RelativePath);
  Reset( archivoLinea );
  tempVar2 := '';
    For i:= 1 To Indice Do
        ReadLn(archivoLinea, tempVar2);
  Close(archivoLinea);
End;

Procedure archivoNegocio(var tempVar2: tRegNegocio; var Indice: integer; linea: Integer; RelativePath: String);
(*  Que hace: obtiene un registro dado de un archivo por su indice y también devuelve su posicion en el archivo.
    precondicones: linea = L, RelativePath = R.
    poscondiciones: tempVar2 = T, Indice = I tempVar2 perteneciente al tipo tRegNegocio
*)
Var
  archivoLinea: tArchNegocio;
  i: Integer;
Begin
    Assign(archivoLinea, RelativePath);
    Reset(archivoLinea ); 
    For i:= 1 To linea Do
        Read(archivoLinea, tempVar2);
    Indice := FilePos(archivoLinea);
    Close(archivoLinea);
End;

procedure CSVaArrRegistro(var Negocios: ArrRegNegocio;var dim: Integer; RelativePath: String);
(*  Que hace: Convierte un CSV a un arreglo de registros.
    precondicones: dim = D, RelativePath = R; el directorio R debe existir.
    poscondiciones: Negocios = N; [1..D] Perteneciente al rango de ArrRegNegocio
*)
var
  contadorLineas, i: Integer;
  lineaRegistro: String;
  Negocio: tRegNegocio;
begin
  
  contadorLineas := contadorLineasArchivo(RelativePath);
  for i:=1 to contadorLineas do
    begin
      lineArchivo(lineaRegistro,i,RelativePath);
      dim := dim + 1;
      cadenaAregistro(Negocio,lineaRegistro);

      Negocios[i] := Negocio
    end;
end;

function articuloVencido(fechaCad: tFecha): boolean;
(*  Que hace: verifica si un articulo está vencido utilizando la fecha actual del sistema y la fecha de caducidad.
    precondicones: fechaCAD = F: F es un tFecha 
    poscondiciones: articuloVencido = V o articuloVencido = F
*)
var
    fecha: tFecha;
    fechaActual: TDateTime;
    a, m, d: Word;
    vencido: boolean;
begin
    //Tomo fecha del sistema
    fechaActual := Date;
    // Decodifico la fecha en anio, mes y dia, devuelve 3 valores de tipo WORD
    DecodeDate(fechaActual, a, m, d);
    //convierto los WORD a integer
    fecha.anio:= Integer(a);
    fecha.mes:= Integer(m);
    fecha.dia:= Integer(d);
    if (fecha.anio > fechaCad.anio) AND (fecha.mes > fechaCad.mes) AND (fecha.dia > fechaCad.dia) then
        vencido := true
    else
        vencido := false;
  articuloVencido := vencido;
end;

function articuloValido(alta: boolean; fechaCad: tFecha): boolean;  
(*  Que hace: Verifica si un articulo es valido por su booleano de alta y la fecha de vencimiento.
    precondicones: alta = N, fechaCAD = F: F es un tFecha 
    poscondiciones: articuloValido = V o articuloValido = F
*)
begin
  if (alta = false)  or (articuloVencido(fechaCad)) then
    articuloValido := false
  else
    articuloValido := true
end;

procedure arrToDat(Negocios: ArrRegNegocio; var secciones: ArrSecciones; var secDim: integer; dim: integer; FilePath: String);

(*  Que hace: convierte un arreglo dado a un .dat, si el archivo no existe lo crea.
    precondicones: Negocios = N, FilePath = F, dim = D: [1..D] perteneciente al rango de ArrRegNegocio.
    poscondiciones: INVENTARIO.DAT de tipo tRegNegocio.
*)
var
  datHandler: tArchNegocio;
  Negocio: tRegNegocio;
  i: integer;
  aux: string;
begin
  aux := '';
  assign(datHandler, FilePath);
  if not FileExists(FilePath) then
    Rewrite(datHandler);
  reset(datHandler);
  for i:= 1 to dim do
  begin
    Negocio := Negocios[i];

    if articuloValido(Negocio.alta, Negocio.fechaCad) then
    begin
    write(datHandler, Negocio);
    end;
    if Negocio.seccion <> aux then
      begin
        secDim := secDim + 1;
        aux := Negocio.seccion;
        secciones[secDim] := aux; 
      end;
  end; 
  Close(datHandler);
end;

function comparar(aSec,aC: string; bSec,bC: string):integer;
begin
//Ordena por seccion y codigo, parte del quicksort
(*  Que hace: compara el negocio a y b segun su seccion y codigo si son iguales.
    precondicones: aSec = aS,aC = AC, bsec = BS, bC= BC.
    poscondiciones: comparar = 0 si son iguales, comparar = 1 si a es mas grande que b, comparar = -1 b es mas grande que a
*)
    if aSec = bSec then
        begin
            if aC = bC then
                comparar := 0
            else if aC > bC then
                comparar := 1
            else 
                comparar := -1
        end
    else if aSec > bSec then
        comparar := 1
    else
        comparar := -1
end;

procedure intercambio(var Negocios: ArrRegNegocio; a, b: integer);
(*  Que hace: intercambia 2 valores de un arreglo.
    precondicones: Negocios = N, a = A, b = B, [A] y [B] dentro del rango valido de ArrRegNegocio
    poscondiciones: Negocios = N'
*)
var
    aux: tRegNegocio;
begin
    aux := Negocios[a];
    Negocios[a] := Negocios[b];
    Negocios[b] := aux;
end;

procedure particion(var Negocios: ArrRegNegocio; principio,final: integer; var pivote: integer);
//quicksort
(*  Que hace: particiona el arreglo utilizando un pivote, todos los menores van a la izquierda del pivote y los demas a la derecha.
    precondicones: Negocios = N, principio = Pr, final = F, pivote = P; Negocios perteneciente al tipo ArrRegNegocio
    poscondiciones: Negocios = N' pivote = P'
*)
var
    pared,j: integer;
    SeccionA,CodigoA,SeccionB,CodigoB: String;
begin
    pivote := final;
    pared := principio - 1;
    for j := principio to final - 1 do
    begin
        SeccionA := Negocios[j].Seccion;
        CodigoA := Negocios[j].codigo;
        SeccionB := Negocios[pivote].seccion;
        CodigoB := Negocios[pivote].codigo;
        if comparar(SeccionA,CodigoA,SeccionB,CodigoB) < 0 then
        begin
            pared := pared + 1;
            intercambio(Negocios, pared, j);
        end;
    end;
    pivote := pared + 1;
    intercambio(Negocios, pivote, final);
end;

procedure quicksort(var Negocios: ArrRegNegocio; principio,final: integer);
//quicksort
(*  Que hace: algortimo recursivo de ordenamiento por seccion y codigo
    precondicones: Negocios = N, principio = P, final = F; N debe ser del tipo ArrRegNegocio y debe estar desordenado.
    poscondiciones: Negocios = N'
*)
var
    posPivote: integer;
begin
    if principio < final then
    begin
        particion(Negocios, principio, final, posPivote);
        quicksort(Negocios, principio, posPivote - 1);
        quicksort(Negocios, posPivote+1, final);
    end;
end;

Procedure ordenArrSeCod(var Negocios: ArrRegNegocio; dim: integer);
(*  Que hace: ordena el arreglo de negocios dado por Seccion y codigo.
    precondicones: Negocios = N, dim = D; [1..D] perteneciente al rango de ArrRegNegocio.
    poscondiciones: Negocios = N'
*)
begin
  Quicksort(Negocios,1, dim);
end;

Function valorMenorADiez(num: integer): string;
// Qué hace: recibe un valor numerico y si el valor numerico es menor a 10 le concatenara un 0 enfrente del numero convertido a cadena o retornara el numero a cadena.
// Precondiciones: recibira un valor entero el cual debe venir inicializado.
// Poscondiciones: devolvera la cadena con un 0 o la cadena intacta, tal comoo  esta.
begin
    if num < 10 then
        valorMenorADiez := '0' + IntToStr(num)
    else
    valorMenorADiez := IntToStr(num);
end;

Function FechAcadena(Fecha: tFecha): String;
var
    cad: string;
begin
    cad := valorMenorADiez(Fecha.dia);
    cad := cad + '/';
    cad := cad + valorMenorADiez(Fecha.mes);
    cad := cad + '/' + IntToStr(Fecha.anio);
    FechAcadena := cad;
end;

Function altaCadena(alta: boolean): string;
begin
    if alta then
    altaCadena := 'SI'
    else
    altaCadena := 'NO';
end;

procedure MostrarNegocio(Negocio: tRegNegocio);
(* que hace: muestra un tRegNegocio dado
    precondiciones: Negocio = N
    poscondiciones: ninguna.
*)
begin
  begin
    write(Negocio.seccion + ', ');
    Write(Negocio.Codigo + ', ');
    Write(Negocio.Nombre+ ', ');
    Write(IntToStr(Negocio.stock)+ ', ');
    Write((FormatFloat('0.0', Negocio.Precio)) + ', ');
    Write(FechAcadena(Negocio.FechaAdq)+ ', ');
    Write(FechAcadena(Negocio.FechaUv)+ ', ');
    Write(FechAcadena(Negocio.FechaCad)+ ', ');
    Write(altaCadena(Negocio.alta));
    writeln;
  end;
end;

procedure listarAltaSeccion(FilePath,seccion: string; bandera: boolean);
(*
    Que hace: Lista los negocios de INVENTARIO.DAT separado por alta dada la seccion y bandera.
    Precondiciones: FilePath = F, seccion = S, bandera = B
    Poscondiciones: Ninguna.
*)
var
FileHandler: tArchNegocio;
Negocio: tRegNegocio;
begin
    Assign(FileHandler, FilePath);
    Reset(FileHandler);
      While not Eof(FileHandler) do
        Begin
            Read (FileHandler,Negocio);
            if Negocio.alta = bandera then
                if LowerCase(Negocio.seccion) = LowerCase(seccion) then
                MostrarNegocio(Negocio)
            else
                if LowerCase(Negocio.seccion) = LowerCase(seccion) then
                MostrarNegocio(Negocio)
        end;
    close(FileHandler);
end;

Function seccionExiste(seccion: string; secciones: ArrSecciones; secDim: integer): boolean;
(*
    Que hace: verifica si la seccion existe dentro del arreglo secciones
    Precondiciones: seccion = S; secciones: S, secDim: SD; [1..SD] perteneciente al tipo secciones
    Poscondiciones: seccionExiste = V o seccionExiste = F
*)
var
i: integer;
bandera: boolean;
begin
    i:= 1;
    bandera :=false;
    while (i <= secDim) and (bandera <> true) do
    begin
    if LowerCase(secciones[i]) = LowerCase(seccion) then
        bandera := True;
    i := i + 1;
    end;
    seccionExiste := bandera;
end;

Procedure listarDAT(FilePath: String;secciones: ArrSecciones; secDim: integer);
(*  Que hace: lista los articulos dados de una seccion separado por el alta.
    Precondiciones: FilePath = F, secciones = S, secDim = SD; [1..SD] perteneciente al tipo ArrSecciones
    Poscondiciones: Ninguna.
*)
var
    seccion: string;
    i: integer;
begin
    writeln('Ingresar una seccion para listar:');
    for i := 1 to secDim do
    begin
        write(secciones[i]);
        if i <> secDim then 
            write(',')
    end;
    writeLn;
    Readln(seccion); 
    if seccionExiste(seccion, secciones, secDim) then
        begin
        writeln('Articulos de alta:');
        listarAltaSeccion(FilePath,seccion,true);
        writeln('Articulos de baja:');
        listarAltaSeccion(FilePath,seccion,false);
        end
    else
        writeln('La seccion no existe;')
end;

Procedure BuscarCodigoArchivo(var Negocio: tRegNegocio; var Indice: integer; FilePath: String; Ini,fin: Integer; codigo:String);
(* Que hace: busca el articulo en el archivo dado el codigo como campo clave, devuelve el articulo y la posicion en el archivo
    Precondiciones: FilePath = File, Ini = I, fin = F codigo = C
    Poscondiciones: Negocio = N, Indice = I*)
Var
p,f,punt,pos: Integer;
begin
    pos := -1;
    p := Ini;
    f := fin;
    While (pos = -1) and (p <= f) DO
    Begin
        punt := (p + f) div 2;
        archivoNegocio(Negocio,Indice,punt,FilePath);
        if (Negocio.Codigo = codigo) then
           pos :=  punt
        else
        begin
            archivoNegocio(Negocio,Indice,punt,FilePath);
            if (Negocio.Codigo > codigo) then
                f := punt-1
            else
            p := punt+1;
            end;
        end;
        //El indice se decrementa debido a una complejidad sobre el indice del arreglo.
        if p>f then 
            Indice := -1
        else
        Indice := Indice - 1
    end;   
    //Restricciones
    procedure MostrarArticulo(Filepath: String);
    (*
        Que hace: muestra un articulo dado si existe
        Precondiciones: FilePath = F el archivo debe de existir
        Poscondiciones: Ninguna*)
    var
        codigo: String; 
        Negocio: tRegNegocio;
        Indice: integer;
    begin
        writeln('Ingresar codigo de articulo formato XXXnnn');
        readln(codigo);
        BuscarCodigoArchivo(Negocio,Indice, FilePath, 1,lineasArchivoNegocio(Filepath),codigo);
        if Indice <> -1 then
            MostrarNegocio(Negocio)
        else
        writeln('Articulo no encontrado')
    end;
    //***********************************************************************//
    function confirma (msj:string):boolean;
    (*
    QUE HACE?:
    PRE:
    POS:
    *)
    var
       respuesta: char;
    begin
        repeat
            writeLn(msj);
            readLn(respuesta);         
        until (respuesta in ['s','n','S','N']);

        if respuesta in ['n','N'] then
        begin
            confirma := TRUE;
        end
        else
        begin
            confirma := FALSE;
        end;
    end;

    function enteroRestriccion(msj: string):integer;
    Var
    Cod, n: integer;
    s: string;
    Begin
    Repeat
        writeln (msj);
        readln(s);
        val(s, n, Cod)
    until Cod = 0;
    enteroRestriccion:= n;
    End;

    //***********************************************************************// 
    function EnteroEnRango(msj: String; tope1,tope2: integer):integer;
    (*Qué hace:
        Solicita al usuario ingresar un valor entre 1 y 5
    Precondición:
        msj = MENSAJE ? dato estructurado; tope1 y tope2 ? a los parametros ingresados 
    Postcondición:
        Devuelve un valor entero n donde 1 <= n <= 5.
    *)
    Var
        valor: Integer;
    begin
        repeat
            valor := enteroRestriccion(msj);
            if (valor < tope1) or (valor > tope2) then
                Write('ERROR: dimension inválida. se espera que el valor ingresado sea entre', tope1,'y', tope2);
        until (valor >= tope1) and (valor <= tope2);
        EnteroEnRango := valor;
    end;
        //***********************************************************************//
    function IngresarNaturalE(msj: String):Integer;
    var
        valor:Integer;
    begin
        Repeat
            valor := enteroRestriccion(msj);
            if valor < 0 then
                Write('ERROR: Ingrese un valor natural correcto');
        until (valor >= 0);
        IngresarNaturalE := valor; //devuelve un natural real
    end;
    //***********************************************************************//
    function IngresarNaturalR(msj: String):Real;
    var
        valor:Real;
    begin
        Repeat            
            valor := enteroRestriccion(msj);
            if valor < 0 then
                Write('ERROR: Ingrese un valor natural correcto');
        until (valor >= 0);
        IngresarNaturalR := valor; //devuelve un natural real
    end;
    //***********************************************************************//
    function Dia(mes:Integer; bisiesto: boolean):Integer;
    begin
        if  bisiesto then
        begin
            case mes of
                1,3,5,7,8,10,12: Dia := EnteroEnRango ('Ingrese un día', 1, 31);
                4,6,9,11: Dia := EnteroEnRango ('Ingrese un día', 1, 30);
                2: Dia := EnteroEnRango ('Ingrese un día', 1, 29);
            end;
        end
        else
        begin
            case mes of
                1,3,5,7,8,10,12: Dia := EnteroEnRango ('Ingrese un día', 1, 31);
                4,6,9,11: Dia := EnteroEnRango ('Ingrese un día', 1, 30);
                2: Dia := EnteroEnRango ('Ingrese un día', 1, 28);
            end;
        end;
    end;
    //***********************************************************************//
    function DiasValido(a:Integer ; m:Integer ):integer;
    begin
        if (a mod 4 = 0) or ((a mod 100 = 0) and (a mod 400 = 0)) then
            DiasValido := Dia(m, True) //biciesto
        else
            DiasValido := Dia(m, false);//no biciesto
    end;    
    //***********************************************************************//
procedure IngresarFecha(msj: String; Var fecha: tFecha);
    (* Qué hace:
        Valida e ingresa una fecha
    Precondición:
        msg=M
    Poscondición:
        fecha = F, F es fecha válida
    *)    
    begin
        writeln(msj);
        fecha.anio := EnteroEnRango('Ingrese un año: ',1900,2300);
        fecha.mes := EnteroEnRango('Ingrese un mes: ', 1, 12);
        fecha.dia := DiasValido(fecha.anio, fecha.mes);  //esta función, en base al año y al mes valida que sea una cantidad de días válido
    end;
    //***********************************************************************// 
function esAlfanumerico(cadena:string):boolean;
(*Qué hace:
    verifica si una cadena es alfanumerica
Precondición:
    cadena = C ∈ string
Postcondición:
    esAlfanumerico = Verdadero si lo es; esAlfanumerico = Falso si no lo es
*)
var
    cont,i,j:integer;
begin
    cont := 0;
    if Length(cadena) = 6 then
    begin
        for i := 1 to 3 do
        begin
            if (cadena[i] in ['A'..'Z']) then
                cont := cont + 1;
        end;
        for j := i to 6 do
        begin
            if (cadena[j] in ['0'..'9']) then
                cont := cont + 1;
        end;
    end;
    

    if cont = 6 then
    begin
        esAlfanumerico := TRUE
    end
    else
    begin
        writeLn('ERROR: no se ingreso una cadena alfanumerica en mayuscula.');
        esAlfanumerico := FALSE;
    end;
end;    

    //***********************************************************************// 
procedure IngresarDatos(var NuevoArt:tRegNegocio; opcion: boolean; ruta: string; dim: integer);
    (*Qué hace:
        ingresa los datos del articulo
    Precondición:
        NuevoArt = Art ∈ tRegNegocio; opcion = V (articulo nuevo) o F (modificar articulo)
    Poscondición:
        si V => Art retorna Art'; si F => Art' retorna Art''
    *)
    var
    aux: string;
    pos: integer;
    Negocio: tRegNegocio;
    begin
        writeln('-------Intgrese los siguientes datos:');
        aux := '';
        if opcion then
        begin
            
            writeln(' * seccion del producto');
            
            while aux = '' do
            begin
            readln(aux);
            if (aux = '') or (aux = ' ') then
                writeln('No se permite ingresar una seccion vacia.')
            end; 
            NuevoArt.Seccion := aux;            

            writeln(' * codigo del producto');
            pos := -2;

            while pos <> -1 do
            begin
            readln(aux);
            if esAlfanumerico(aux) then
            begin
                BuscarCodigoArchivo(Negocio, pos, ruta, 1, dim, aux);
            end;     
        
            if pos = 0 then
                writeln('ERROR: este produccto ya existe, re-ingresar');
            end;
            NuevoArt.Codigo := aux;    
        end;

        write(' * nombre del producto');
        readln(NuevoArt.Nombre);

        NuevoArt.Stock := IngresarNaturalE(' * stock actual del producto');
        NuevoArt.Precio := IngresarNaturalR(' * precio del producto');

        Repeat 
            IngresarFecha(' * Fecha de adquisición', NuevoArt.FechaAdq);
            IngresarFecha(' * Fecha de caducidad', NuevoArt.FechaCad);

            if NuevoArt.FechaAdq.anio > NuevoArt.FechaCad.Anio then
                writeln('Se ha ingresado una fecha de caducidad superior a la de adquisición')

        Until (NuevoArt.FechaAdq.anio < NuevoArt.FechaCad.Anio);

        IngresarFecha(' *  Fecha de última venta', NuevoArt.FechaUv);

        if opcion then
            NuevoArt.alta := confirma('alta de producto? S/N');
    end;

    //***********************************************************************// 
    procedure InsertarOrdenado(var arch: tArchNegocio; NuevoReg: tRegNegocio);
    (*Qué hace:
        Agrega el articulo de manera ordenada
    Precondición:
        arch = archivo ya abierto y ordenado; NuevoReg ∈ tRegNegocio
    Poscondición:
        arch = arch' de manera ordenada
    *)
    var
        pos: Integer;
        articulo: tRegNegocio;
        lugar:boolean;
    begin
        pos := FileSize(arch)-1;
        lugar := false;
        while (pos >= 0) and (not lugar) do
        begin
            seek(arch, pos);
            read (arch, articulo);

            if (comparar(NuevoReg.seccion,NuevoReg.codigo,articulo.seccion,articulo.codigo) < 0) then
            begin
                Write (arch, articulo);
                pos := pos-1;
            end
            else
            begin
                lugar := TRUE;
            end;
        end;
        seek(arch, pos+1);
        Write (arch, NuevoReg);
    end;

    //***********************************************************************//  
procedure DarAltaArticulo(ruta :String; var dim:Integer; var secciones:  ArrSecciones; var secDim: Integer);
    (*Qué hace:
        da de alta un producto
    Precondición:
        ruta = Narch; dim = dim de arch
    Poscondición:
        dim = dim + 1 si pos = -1
    *)
    var
        NuevoArt: tRegNegocio;
        archInventario: tArchNegocio; 
    begin
        IngresarDatos(NuevoArt,True,ruta,dim);
        Assign(archInventario, ruta);
        reset(archInventario);    
        InsertarOrdenado(archInventario, NuevoArt);
        close(archInventario);
        dim := dim+1;
        writeln('¡Listado con exito! :)');  

        if seccionExiste(NuevoArt.seccion,secciones,secDim) = false then
        begin
            secDim := secDim + 1;
            secciones[secDim] := NuevoArt.seccion;
        end;      

    end;
    
//Restricciones.
procedure EliminarArticulo(FilePath: string; secciones: ArrSecciones; secDim: integer);
(*
    Que hace: Da de baja logicamente un articulo del INVENTARIO.DAT
    Precondiciones: FilePath = F secciones = S secDim = SD; [1..SD] perteneciente al tipo ArrSecciones
    Poscondiciones: INVENTARIO.DAT con el articulo eliminado logicamente
*)
var
    FileHandler: tArchNegocio;
    codigo: String; 
    Negocio: tRegNegocio;
    i,Indice: integer;
begin
    for i := 1 to secDim do
    begin
        listarAltaSeccion(FilePath,secciones[i],true);
    end;
    writeln('Ingresar codigo de articulo formato XXXnnn, para desactivar');
    readln(codigo);
    BuscarCodigoArchivo(Negocio,Indice, FilePath, 1,lineasArchivoNegocio(FilePath),codigo);

    if Indice <> -1 then
    begin
        Negocio.Alta := False;
        Assign(FileHandler, FilePath);
        Reset(FileHandler);
        Seek(FileHandler, Indice);
        write(FileHandler,Negocio);
        close(FileHandler);
    end
    else
        writeln('El articulo no existe.')
end;

//Restricciones
procedure ActivarArticuloDeBaja(FilePath: string; secciones: ArrSecciones; secDim: integer);
(*Que hace: Activa logicamente un articulo dado de baja del INVENTARIO.DAT
  Precondiciones: FilePath = F, secciones = S secDim = SD
  Poscondiciones: INVENTARIO.DAT con el acrticulo logicamente activado.*)
var
    FileHandler: tArchNegocio;
    codigo: String; 
    Negocio: tRegNegocio;
    i: integer;
    Indice: integer;
begin
    for i := 1 to secDim do
    begin
        listarAltaSeccion(Filepath,secciones[i],false);
    end;
    writeln('Ingresar codigo de articulo formato XXXnnn, para activar');
    readln(codigo);
    BuscarCodigoArchivo(Negocio,Indice, FilePath, 1,lineasArchivoNegocio(Filepath),codigo);
    if Indice <> -1 then
        begin
        Negocio.Alta := true;
        Assign(FileHandler, FilePath);
        Reset(FileHandler);
        Seek(FileHandler, Indice);
        write(FileHandler,Negocio);
        close(FileHandler);
    end
    else
        writeln('El articulo no existe')
end;

function concatenarAlta(logico:boolean): string;

// Qué hace: recive valor logico, si este valor es verdadero devolvera un un SI, de lo contrario si el logico es falso devolvera un NO
// Precondiciones: debe ingresar un valor logico
// Poscondiciones: devolvera una cadena con SI o con NO

begin
     if (logico)then
        concatenarAlta:= 'SI'
     else
         concatenarAlta:= 'NO';
end;

function fechaACadena(reg:tFecha): string;

// Qué hace: recive un registro de tipo tFecha para concatenar las fechas en este formato dia/mes/año y devuelve una cadena
// Precondiciones: el registro debe venir inicializado, si no podria devolver cualquier tipo de informacion erronea
// Poscondiciones: al devolver una cadena debe haber algo que lo reciva o la informacion se perdera
var
   cad: string;
begin
    cad:='';
    cad:= cad + valorMenorADiez(reg.dia);
    cad:=cad + '/';
    cad:= cad +valorMenorADiez(reg.mes);
    cad:=cad + '/';
    cad:=cad + intToStr(reg.anio);
    fechaACadena:=cad;
end;
    //***********************************************************************//  
    procedure ModArticuloDeAlta(ruta: string; dim: Integer);
    (* Qué hace:
        permite modificar un articulo
    Precondición:
        ruta = Narch; dim = dim de arch
    Poscondición:
        arch = arch' si pos <> -1
    *)
    var
        pos: Integer;
        NuevoArt: tRegNegocio;
        negocio: tRegNegocio;
        archInventario: tArchNegocio; 
        aux: string;
    begin  
        pos := -1;
        while pos = -1 do
            begin
            writeLn('Ingresar codigo del articulo que desea modificar');
            readln(aux);
            if esAlfanumerico(aux) then
            begin
                BuscarCodigoArchivo(negocio, pos, ruta, 1, dim, aux);
            if pos = -1 then
                writeln('el articulo no existe, ingresar otro')
            end;
        end;
            //Aca se podria usar directamente negocio, pero capaz se lee mejor de está forma...
            NuevoArt := negocio;
            if (not confirma('Estas seguro de querer modificar este articulo?')) then
            begin
                IngresarDatos(NuevoArt,false,ruta,dim);
                Assign(archInventario, ruta);
                reset(archInventario);
                seek(archInventario, pos);
                Write (archInventario, NuevoArt);
                close(archInventario);                
            end;            
        writeln('Articulo modificado con exito');
    end;
    //***********************************************************************//   

function pasarDatosAcadena(reg: tRegNegocio):string;
// Qué hace: se encarga de pasar todos los datos del registro a cadena y concatena tododos estos para devolver todo una cadena con todos los datos del registro separados por una ","
// Precondiciones: el registro el cual es recibido por esta funcion debera venir previamente inicializado, o podria devolver informacion erronea
// Poscondiciones: esta funcion devolvera una cadena asi que debe tener lugar donde guardarla o usarla
var
   cad: string;
begin
    cad := '';
     cad:=(cad + reg.seccion);
     cad:=(cad + ',');
     cad:=(cad + reg.codigo);
     cad:=(cad + ',');
     cad:=(cad + reg.nombre);
     cad:= (cad + ',');
     cad:=(cad + intToStr(reg.stock));
     cad:=(cad + ',');
     cad:=(cad + floatToStr(reg.precio));
     cad:=(cad + ',');
     cad:=(cad + fechaACadena(reg.fechaAdq));
     cad:=(cad + ',');
     cad:=(cad + fechaACadena(reg.FechaUv));
     cad:=(cad + ',');
     cad:=(cad + fechaACadena(reg.FechaCad));
     cad:=(cad + ',');
     cad:=(cad + concatenarAlta(reg.alta));
     pasarDatosAcadena:=cad;
end;

procedure Exportar(nombreDat: string);
//Qué hace: recibe el nombre del archivo dat, o su ruta para conectarse con el archivo.DAT, crea un archivo CSV, lee el archivo.dat y llama a un sub algoritmo que pasa todos los datos del DAT, al CSV hasta que el DAT no tenga mas informacion
//Precondiciones: necesita el nombre o la ruta del archivo.DAT, y que el archivo dat si exista, si no el procedimiento no funcionara, ademas de que el dat debe ser de tipo tRegNegocio
//Poscondiciones: nada, ya que crea el CSV y no devuelve nada
var
   DAT: tarchNegocio;
   CSV: text;
   Reg: tRegNegocio;
   cad: string;
begin

    assign(DAT,nombreDat);
    reset(DAT);
    assign(CSV,'NUEVO_INVENTARIO.CSV');
    rewrite(CSV);
    while not Eof(DAT) do
    begin
        read (DAT, reg);
        cad:=pasarDatosAcadena(reg);
        Writeln(CSV,cad);
    end;
    close(CSV);
    close(DAT);

end;

    //***********************************************************************//       
    function Menu():integer;
    begin
        writeln(' _______   __    __            __       __                      __                   __     ');
        writeln('|       \ |  \  |  \          |  \     /  \                    |  \                 |  \    ');
        writeln('| $$$$$$$\ \$$ _| $$_         | $$\   /  $$  ______    ______  | $$   __   ______  _| $$_   ');
        writeln('| $$__/ $$|  \|   $$ \        | $$$\ /  $$$ |      \  /      \ | $$  /  \ /      \|   $$ \  ');
        writeln('| $$    $$| $$ \$$$$$$        | $$$$\  $$$$  \$$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$\\$$$$$$  ');
        writeln('| $$$$$$$\| $$  | $$ __       | $$\$$ $$ $$ /      $$| $$   \$$| $$   $$ | $$    $$ | $$ __ ');
        writeln('| $$__/ $$| $$  | $$|  \      | $$ \$$$| $$|  $$$$$$$| $$      | $$$$$$\ | $$$$$$$$ | $$|  \');
        writeln('| $$    $$| $$   \$$  $$      | $$  \$ | $$ \$$    $$| $$      | $$  \$$\ \$$     \  \$$  $$');
        writeln(' \$$$$$$$  \$$    \$$$$        \$$      \$$  \$$$$$$$ \$$       \$$   \$$  \$$$$$$$   \$$$$  ');
        
        Writeln('Menu:');
        Writeln('   0. Para salir');
        Writeln('   1. Dar de alta un artículo');
        Writeln('   2. Modificar un artículo de alta');
        Writeln('   3. Eliminar un artículo ');
        Writeln('   4. Activar un artículo de baja');  
        Writeln('   5. Mostrar un artículo');
        Writeln('   6. Listar todos los artículos de una sección');
        Writeln('   7. Exportar a CSV');
        Menu := EnteroEnRango('ingrece alguna opcion:', 0, 7);   
        fpsystem('clear');
    end;

//******************************************************************//
//************************ALG_PRINCIPAL*****************************//
//******************************************************************//
var
Negocios: ArrRegNegocio;
secDim,dim,opcion: integer;
secciones: ArrSecciones;

const

archivoDAT = 'INVENTARIO.DAT';
begin
    secDim := 0;
    dim := 0;
    //levanto el csv a un arreglo de registros.
    CSVaArrRegistro(Negocios,dim,'SUCURSAL_CENTRO.CSV');
    //listar(Negocios, dim);
    //ordeno el arreglo por seccion y codigo.
    ordenArrSeCod(Negocios,dim);
    //listar(Negocios, dim);
    //convierto el arreglo ordenado a .dat
    arrToDat(Negocios,secciones,secDim, dim,archivoDAT);    
    opcion := -1;
    while opcion <> 0 do
    begin
        opcion := Menu();
        case opcion of
            1:DarAltaArticulo(archivoDAT, dim,secciones,secDim);
            2: ModArticuloDeAlta(archivoDAT,dim);
            3: EliminarArticulo(archivoDAT,secciones,secDim);
            4: ActivarArticuloDeBaja(archivoDAT,secciones,secDim);
            5: MostrarArticulo(archivoDAT);
            6: listarDAT(archivoDAT,secciones,secDim);
            7: Exportar(archivoDAT);
        end;
    end;
end.