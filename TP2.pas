
Program BitMarket;
uses SysUtils;

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
  Precondiciones: Fecha = F, aux = A Fecha perteneciente al tipo tFecha y aux con formato: DD/MM/YYYY.
  Poscondiciones: Fecha = F'
*)
var
 i: Integer;
 strNumber: String;
 caracterAux: char;
 slash: Integer;
begin
  slash := 0;
  i := 1;  
    
    while slash <= 2 do
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

        case slash of
          0: Fecha.dia := StrToInt(strNumber);
          1: Fecha.mes := StrToInt(strNumber);
          2: Fecha.anio := StrToInt(strNumber);
        end;
        slash := slash + 1;  
    end;
end;
    
function cadenAlogico(aux: String):boolean;
//aux = verdadero si la cadena tiene S
(*  Que hace: verifica si un caracter es 'S'
    precondicones: aux = A
    poscondiciones: cadenAlogico = V o cadenAlogico = F
*)
begin
  cadenAlogico := aux = 'S';
end;

procedure cadenaAregistro(var Negocio: tRegNegocio; cadReg: String);
//convierte una linea de una cadena a un tipo registro
(*  Que hace: convierte una cadena dada separada por , con cada valor a un tRegNegocio.
    precondicones: Negocio = N, cadReg = C cadReg mantiene el orden 'Seccion,Codigo,Nombre,Stock,Precio,DD/MM/YYYY,DD/MM/YYYY,DD/MM/YYYY,alta'
    poscondiciones: Negocio = N'
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


function getFileLinesCount(FilePath: String): Integer;
//Obtiene la cantidad de lineas de un archivo
(*  Que hace: cuenta la cantidad de lineas de un archivo.
    precondicones: FilePath = F y el directorio debe existir.
    poscondiciones: getFileLinesCount = n
*)
var
  FileText: tArchText;
  LineCount: Integer;
  tempS: String;
begin
  Assign(FileText, FilePath);
  Reset(FileText);
  LineCount := 0;
  while not EoF(FileText) do
  begin
    ReadLn(FileText, tempS);
    LineCount := LineCount + 1;
  end;
  close(FileText);
  getFileLinesCount := LineCount;
end;


function getFileLinesArchiveCount(FilePath: String): Integer;
//Obtiene la cantidad de lineas de un archivo
(*  Que hace: cuenta la cantidad de lineas de un archivo.
    precondicones: FilePath = F y el directorio debe existir.
    poscondiciones: getFileLinesCount = n
*)
var
  FileText: tArchNegocio;
  LineCount: Integer;
  tempS: tRegNegocio;
begin
  Assign(FileText, FilePath);
  Reset(FileText);
  LineCount := 0;
  while not EoF(FileText) do
  begin
    Read(FileText, tempS);
    LineCount := LineCount + 1;
  end;
  close(FileText);
  getFileLinesArchiveCount := LineCount;
end;

Procedure getFileLine(var tempVar2: String; index: Integer; RelativePath: String);
//obtiene una linea dada por el bucle for, dios sabe por que esto funciona así.
(*  Que hace: obtiene una linea dado de un archivo dado
    precondicones: tempVar2 = T, index = I, RelativePath = R.
    poscondiciones: tempVar2 = T'
*)
Var
  FileLineHandler: tArchText;
  i: Integer;
Begin
  Assign(FileLineHandler, RelativePath);
  Reset( FileLineHandler );
  tempVar2 := '';
  //Esta cosa necesita una explicación: https://stackoverflow.com/questions/64556659/how-to-read-a-specific-line-from-a-text-file-in-pascal
      For i:= 1 To index Do
      ReadLn(FileLineHandler, tempVar2);
  Close(FileLineHandler);
End;

//Obtiene un archivo dado por una linea
Procedure getFileBusiness(var tempVar2: tRegNegocio; var Indice: integer; linea: Integer; RelativePath: String);
(*  Que hace: obtiene una linea dado de un archivo dado
    precondicones: tempVar2 = T, linea = L, RelativePath = R.
    poscondiciones: tempVar2 = T'
*)
Var
  FileLineHandler: tArchNegocio;
  i: Integer;
Begin
  Assign(FileLineHandler, RelativePath);
  Reset(FileLineHandler );
  //Esta cosa necesita una explicación: https://stackoverflow.com/questions/64556659/how-to-read-a-specific-line-from-a-text-file-in-pascal
    For i:= 1 To linea Do
        Read(FileLineHandler, tempVar2);
  Indice := FilePos(FileLineHandler);
  Close(FileLineHandler);
End;

//Faltan agregar restricciones
procedure CSVaArrRegistro(var Negocios: ArrRegNegocio;var dim: Integer; RelativePath: String);
//Convierte un CSV a un arreglo de registros.
(*  Que hace: Convierte un CSV dado con registros de tRegNegocio y los mete a un arreglo del mismo tipo.
    precondicones: Negocios = N, dim = D, RelativePath = R; [1..D] Perteneciente al rango de ArrRegNegocio y el directorio R existe.
    poscondiciones: Negocios = N' 
*)
var
  linesCount, i: Integer;
  LineRegister: String;
  Negocio: tRegNegocio;
begin
  
  linesCount := getFileLinesCount(RelativePath);
  for i:=1 to linesCount do
    begin
      getFileLine(LineRegister,i,RelativePath);
      dim := dim + 1;
      cadenaAregistro(Negocio,LineRegister);

      Negocios[i] := Negocio
    end;
end;

function articuloVencido(Negocio: tRegNegocio): boolean;
//Verifica si un articulo esta vencido utilizando la fecha de adquisición 
// y la de caducidad

(*  Que hace: verifica si un articulo está vencido utilizando la fecha de adquisición y la fecha de caducidad.
    precondicones: Negocio = N del tipo tRegNegocio.
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

    if (fecha.anio > Negocio.fechaCad.anio) AND (fecha.mes > Negocio.fechaCad.mes) AND (fecha.dia > Negocio.fechaCad.dia) then
        vencido := true
    else
        vencido := false;

  articuloVencido := vencido;
end;

function articuloValido(Negocio: tRegNegocio): boolean;  
//Verifica si un articulo es valido.
(*  Que hace: Verifica si un articulo es valido por su booleano de alta y la fecha de vencimiento.
    precondicones: Negocio = N 
    poscondiciones: articuloValido = V o articuloValido = F
*)
begin
  if (Negocio.alta = false)  or (articuloVencido(Negocio)) then
    articuloValido := false
  else
    articuloValido := true
end;

procedure arrToDat(Negocios: ArrRegNegocio; var secciones: ArrSecciones; var secDim: integer; dim: integer; FilePath: String);
//convierte un arreglo ordenado de negocios a un .dat dado
(*  Que hace: convierte un arreglo dado a un .dat, si el archivo no existe lo crea.
    precondicones: Negocios = N, FilePath = F, dim = D: [1..D] perteneciente al rango de ArrRegNegocio.
    poscondiciones: Ninguna.
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

    if articuloValido(Negocio) then
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

function comparar(a,b: tRegNegocio):integer;
begin
//Ordena por seccion y codigo, parte del quicksort
(*  Que hace: compara el negocio a y b segun su seccion y codigo si son iguales.
    precondicones: a = A, b = B perteneciente al tipo tRegNegocio.
    poscondiciones: comparar = 0, comparar = 1, comparar = - 1
*)
    if a.seccion = b.seccion then
        begin
            if a.codigo = b.codigo then
                comparar := 0
            else if a.codigo > b.codigo then
                comparar := 1
            else 
                comparar := -1
        end
    else if a.seccion > b.seccion then
        comparar := 1
    else
        comparar := -1
end;

procedure intercambio(var Negocios: ArrRegNegocio; a, b: integer);
//intercamba 2 posiciones en un arreglo de negocios dado
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
(*  Que hace:
    precondicones:
    poscondiciones:
*)
var
    pared,j: integer;
begin
    pivote := final;
    pared := principio - 1;
    for j := principio to final - 1 do
    begin
        if comparar(Negocios[j], Negocios[pivote]) < 0 then
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
(*  Que hace:
    precondicones:
    poscondiciones:
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

Function valorMenorADiez(a: integer): string;
begin
    if a < 10 then
        valorMenorADiez := '0' + IntToStr(a)
    else
    valorMenorADiez := IntToStr(a);
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

//Este algoritmo deberia ser eliminado para la entrega.
procedure MostrarNegocio(Negocio: tRegNegocio);
(* que hace: itera y muestra la seccion y codigo de un arreglo de negocios dado.
    solamente para testear.
    precondiciones: Negocios = N, dim = D; [1..D] perteneciente al rango de ArrRegNegocio.
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
//Pregunta en este caso listar el alta y baja es muy ineficiente leerlo del archivo, en este caso se puede usar un arreglo?
//Also aca tambien se podria implementar 2 archivos temporales de alta y baja para que el algoritmo no itere al pedo.
procedure listarAltaSeccion(FilePath,seccion: string; bandera: boolean);
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
                if Negocio.seccion = seccion then
                MostrarNegocio(Negocio)
            else
                if Negocio.seccion = seccion then
                MostrarNegocio(Negocio)
        end;
    close(FileHandler);
end;


//Unificar 
Procedure listarDAT(FilePath: String;secciones: ArrSecciones; secDim: integer);
var
    seccion: string;
    i: integer;
begin
    write('Ingresar una seccion para listar:');
    for i := 1 to secDim do
    begin
        write(secciones[i] + ',');
    end;

    Readln(seccion);
    writeln('Articulos de alta:');
    listarAltaSeccion(FilePath,seccion,true);
    writeln('Articulos de baja:');
    listarAltaSeccion(FilePath,seccion,false);
end;
//--------------------------------------------------- Inicio del algoritmo ---------------------------------------------------.

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
    //***********************************************************************//
    function nReal (msj : string):Real;
    Var
        Cod, n: integer;
        s: string;
    Begin
        Repeat
            writeln (msj);
            readln(s);
            val(s, n, Cod)
        until Cod = 0;
        nReal:= n;
    End;
    //***********************************************************************// 
        function entero (msj : string):Integer;
    Var
        Cod, n: integer;
        s: string;
    Begin
        Repeat
            writeln (msj);
            readln(s);
            val(s, n, Cod)
        until Cod = 0;
        entero:= n;
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
            valor := entero(msj);
            if (valor < tope1) or (valor > tope2) then
                Write('ERROR: dimension inválida. se espera que el valor ingresado sea entre', tope1,'y', tope2);
        until (valor in [tope1..tope2]);
        EnteroEnRango := valor;
    end;
        //***********************************************************************//
    function IngresarNaturalE(msj: String):Integer;
    var
        valor:Integer;
    begin
        Repeat            
            valor := entero(msj);
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
            valor := nReal(msj);
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
    (* Qué hace: Valida e ingresa una fecha
    Prec: msg=M
    Posc:fecha = F, F es fecha válida
    *)    
    begin
        writeln(msj);
        fecha.anio := EnteroEnRango('Ingrese un año: ', 1900, 2300);
        fecha.mes := EnteroEnRango('Ingrese un mes: ', 1, 12);
        fecha.dia := DiasValido(fecha.anio, fecha.mes);  //esta función, en base al año y al mes valida que sea una cantidad de días válido
    end;
    //***********************************************************************// 
    procedure IngresarDatos(var NuevoArt:tRegNegocio);
    begin
        writeln('-------Intgrese los siguientes datos:');
        write(' 1. seccion del producto');
        readln(NuevoArt.Seccion);
        write(' 2. codigo del producto');
        readln(NuevoArt.Codigo);
        write(' 3. nombre del producto');
        readln(NuevoArt.Nombre);

        NuevoArt.Stock := IngresarNaturalE(' 4. stock actual del producto');
        NuevoArt.Precio := IngresarNaturalR(' 5. precio del producto');

        IngresarFecha(' 6. Fecha de adquisición', NuevoArt.FechaAdq);
        IngresarFecha(' 7.  Fecha de última venta', NuevoArt.FechaUv);
        IngresarFecha(' 8. Fecha de caducidad', NuevoArt.FechaCad);
        NuevoArt.alta := confirma('Dar el producto de alta? S/N');
        
    end;

    //***********************************************************************//
    function BuscarCodigo(List: ArrRegNegocio; Ini:Integer; fin: Integer; E:String):integer;
    Var
        p,f,punt,pos: Integer;
    begin
        pos := -1;
        p := Ini;
        f := fin;
        
        While (pos = -1) and (p <= f) DO
        Begin
            punt := (p + f) div 2;

            if (list[punt].Codigo = E) then
                pos :=  punt
            else
            begin
                if (list[punt].Codigo > E) then
                    f := punt-1
                else
                    p := punt+1;
            end;
        end;
        BuscarCodigo := pos;
        
    end;
    //***********************************************************************//  
    procedure DarAltaArticulo(var Negocio:ArrRegNegocio; var dim:Integer; max:Integer);
    var
        pos: Integer;
        NuevoArt: tRegNegocio;
    begin
        if dim <= max then
        begin
            write('Ingrese el codigo del producto');
            readln(NuevoArt.Codigo);

            pos := BuscarCodigo(negocio, 1, dim, NuevoArt.Codigo);

            if pos = -1 then //si es un articulo nuevo
                IngresarDatos(NuevoArt)
                //InsertarOrdenado (Negocio, dim, NuevoArt);
            else
                writeln('ERROR: este produccto ya existe');
        end
        else
            begin
               writeln('ATENCION!!: Limite de almacenamiento alcanzado');
            end;
    end;
    //Si el algoritmo se ordeno por seccion y codigo, la busqueda tambien puede hacerse por seccion y codigo?
    //Utilizar de alguna forma entero en rango
 
    //Duplicado
    Procedure BuscarCodigoArchivo(var Negocio: tRegNegocio; var Indice: integer; FilePath: String; Ini,fin: Integer; E:String);
    Var
        p,f,punt,pos: Integer;
    begin
        pos := -1;
        p := Ini;
        f := fin;
        While (pos = -1) and (p <= f) DO
        Begin
            punt := (p + f) div 2;
            getFileBusiness(Negocio,Indice,punt,FilePath);
            if (Negocio.Codigo = E) then
                pos :=  punt
            else
            begin
            getFileBusiness(Negocio,Indice,punt,FilePath);
                if (Negocio.Codigo > E) then
                    f := punt-1
                else
                    p := punt+1;
            end;
        end;
        //El indice se decrementa debido a una complejidad sobre el indice del arreglo.
        Indice := Indice - 1;
    end;
    // hasta aca, copiar y pegar al anterior
    procedure MostrarArticulo(Filepath: String);
    var
        codigo: String; 
        Negocio: tRegNegocio;
        Indice: integer;
    begin
        write('Ingresar codigo de articulo formato XXXnnn');
        readln(codigo);
        BuscarCodigoArchivo(Negocio,Indice, FilePath, 1,getFileLinesArchiveCount(Filepath),codigo);
        MostrarNegocio(Negocio);
    end;

    procedure EliminarArticulo(FilePath: string; secciones: ArrSecciones; secDim: integer);
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
        write('Ingresar codigo de articulo formato XXXnnn, para desactivar');
        readln(codigo);
        BuscarCodigoArchivo(Negocio,Indice, FilePath, 1,getFileLinesArchiveCount(FilePath),codigo);
        Negocio.Alta := False;

        Assign(FileHandler, FilePath);
        Reset(FileHandler);
        Seek(FileHandler, Indice);
        write(FileHandler,Negocio);
        close(FileHandler);

    end;

    procedure ActivarArticuloDeBaja(FilePath: string; secciones: ArrSecciones; secDim: integer);
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

        write('Ingresar codigo de articulo formato XXXnnn, para activar');
        readln(codigo);
        BuscarCodigoArchivo(Negocio,Indice, FilePath, 1,getFileLinesArchiveCount(Filepath),codigo);
        Negocio.Alta := true;

        Assign(FileHandler, FilePath);
        Reset(FileHandler);
        Seek(FileHandler, Indice);
        write(FileHandler,Negocio);
        close(FileHandler);
        
    end;
    //***********************************************************************//       
    function Menu(msj: String):integer;
    begin
        Writeln(msj);
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
    end;

//******************************************************************//
//************************ALG_PRINCIPAL*****************************//
//******************************************************************//

var
//variables de prueba, borrar al final.
//Negocio: tRegNegocio;
//NegocioArchivo: tArchNegocio;
Negocios: ArrRegNegocio;
secDim,dim,opcion: integer;
secciones: ArrSecciones;
i: integer;
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
    arrToDat(Negocios,secciones,secDim, dim,'INVENTARIO.DAT');    

    opcion := -1;
    while opcion <> 0 do
    begin
        opcion := Menu('-------------“Bit Market”-------------');
        //El filepath siempre deberia ser una copia del original para el tema de agregar, eliminar, guardar o deshacer cambios, etc.
        case opcion of
            1:DarAltaArticulo(Negocios, dim, max);
            //2: ModArticuloDeAlta(Negocios);
            3: EliminarArticulo('INVENTARIO.DAT',secciones,secDim);
            4: ActivarArticuloDeBaja('INVENTARIO.DAT',secciones,secDim);
            5: MostrarArticulo('INVENTARIO.DAT');
            6: listarDAT('INVENTARIO.DAT',secciones,secDim);
            //7: Exportar(Negocios);
        end;
    end;
end.