
Program HellyeahSimulator;
uses SysUtils;
//NO copiar
Procedure leerCSV(RelativePath: String);
Var S : String;
    C : Char;
    F : File of char;

//Leer csv por pantalla caracter por caracter
begin
  Assign (F,RelativePath);
  Reset (F);
  C:='A';
  Writeln ('The characters before the first space in SUCURSAL_CENTRO.CSV are : ');
  While not Eof(f) do
    Begin
    Read (F,C);
    Write (C);
    end;
 Writeln;
 Close (F);
 Writeln ('Type some words. An empty line ends the program.');
 repeat
   Readln (S);
 until S='';
end;

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
  Precio: Integer;
  FechaAdq: tFecha;
  FechaUv: tFecha;
  FechaCad: tFecha;
  alta: boolean
end;

ArrRegNegocio = Array [1..500] of tRegNegocio;

//Esto da asco también
procedure cadenAfecha(var Fecha: tFecha; aux: String);
(* Que hace: Recibe una cadena y devuelve un tipo tfecha
  Precondiciones: Fecha = F, aux = A Fecha perteneciente al tipo tFecha.
  Poscondiciones: F
*)
var
 i: Integer;
 strNumero: String;
 barra: Integer;
begin
  barra := 0;
  strNumero:= '';
  for i := 1 to Length(aux) do
  begin
    strNumero := aux[i];
    if strNumero = '/' then 
    begin
      strNumero := '';
      barra := barra + 1;
    end; 

    case barra of
      //En los valores nulos pascal devuelve 0, es valido esto?
      //Linda ese casting eh
      0: Fecha.dia := StrToInt(IntToStr(Fecha.dia) + strNumero);
      1: Fecha.mes := StrToInt(IntToStr(Fecha.mes) + strNumero);
      2: Fecha.anio := StrToInt(IntToStr(Fecha.anio) + strNumero);
    end;
  end;
end;
    
function cadenAlogico(aux: String):boolean;
begin
  cadenAlogico := aux = 'S';
end;

procedure cadenaAregistro(var Negocio: tRegNegocio; cadReg: String);
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
          5: Negocio.Precio := StrToInt(aux);
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


function obtenerLineasArchivo(Archivo: String): Integer;
var
  ArchivoTexto: Text;
  LineCount: Integer;
  tempS: String;
begin
  Assign(ArchivoTexto, Archivo);
  Reset(ArchivoTexto);
  LineCount := 0;
  while not EoF(ArchivoTexto) do
  begin
    ReadLn(ArchivoTexto, tempS);
    LineCount := LineCount + 1;
  end;
  close(ArchivoTexto);
  obtenerLineasArchivo := LineCount;
end;
Procedure ObtenerLineArchivo(var tempVar2: String; index: Integer; RelativePath: String);
Var
  FileLineHandler: Text;
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

//Faltan agregar restricciones
procedure CSVaArrRegistro(var Negocios: ArrRegNegocio; dim: Integer;RelativePath: String);
var
  linesCount, i: Integer;
  LineRegister: String;
  Negocio: tRegNegocio;
begin
  linesCount := obtenerLineasArchivo(RelativePath);
  for i:=1 to linesCount do
    begin
      ObtenerLineArchivo(LineRegister,i,RelativePath);
      dim := dim + 1;
      cadenaAregistro(Negocio,LineRegister);
      Negocios[i] := Negocio
    end;
end;

//generar un archivo de registros
//si el articulo esta de baja no se cuenta
//si esta vencido no se tiene en cuenta
//ordenado por clave
function articuloBaja(Negocio: tRegNegocio): boolean;
begin
  articuloBaja := Negocio.alta;
end;

function articuloVencido(Negocio: tRegNegocio): boolean;
var
  fechaAdq: tFecha;
  fechaCad: tFecha;
  vencido: boolean;
begin
  fechaAdq := Negocio.fechaAdq;
  fechaCad := Negocio.fechaCad;

  if (fechaAdq.anio > fechaCad.anio) then
    vencido := true
  else if (fechaAdq.anio < fechaCad.anio) then
    vencido := false
  else if (fechaAdq.mes > fechaCad.mes) then
    vencido := true
  else if (fechaAdq.mes < fechaCad.mes) then
    vencido := false
  else if (fechaAdq.dia > fechaCad.dia) then
    vencido := true
  else
    vencido := false;
  articuloVencido := vencido;
end;

function articuloValido(Negocio: tRegNegocio): boolean;  
begin
  if (articuloBaja(Negocio)) or (articuloVencido(Negocio)) then
    articuloValido := false
  else;
    articuloValido := true;
end;

procedure arrAdat(Negocios: ArrRegNegocio; Archivo: String);
var
  datHandler: file of tRegNegocio;
  i: integer;
begin
  
  assign(datHandler, Archivo);
  if not FileExists(Archivo) then
    Rewrite(datHandler);
  reset(datHandler);
  for i:= 0 to Length(Negocios) do
  begin
    if articuloValido(Negocios[i]) then
      write(datHandler, Negocios[i]);
  end;
  Close(datHandler);
end;

function comparar(a,b: tRegNegocio):integer;
begin
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
var
    aux: tRegNegocio;
begin
    aux := Negocios[a];
    Negocios[a] := Negocios[b];
    Negocios[b] := aux;
end;

procedure particion(var Negocios: ArrRegNegocio; principio,final: integer; var pivote: integer);
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
begin
  Quicksort(Negocios,1, dim);
end;

procedure listar(Negocios: ArrRegNegocio);
var
i: integer;
begin
  for i:=1 to 30 do 
  begin
    Writeln(Negocios[i].seccion);
    Writeln(Negocios[i].codigo);
  end;
end;

var
Negocio: tRegNegocio;
Negocios: ArrRegNegocio;
begin
//importante para mostrar un tipo real.
//FormatFloat('0.0', real)

  //Negocio de prueba;
  //Negocio.Seccion := 'Trusty almacen'; Negocio.Codigo := 10; Negocio.Nombre := 'Pochoclos'; Negocio.Stock := 15; Negocio.Precio := 1500; cadenAfecha(Negocio.FechaAdq, '02/09/2011'); cadenAfecha(Negocio.FechaUv, '01/03/2025'); cadenAfecha(Negocio.FechaCad, '01/09/2011'); Negocio.alta := false; 
  
  //crear arreglo del csv
  CSVaArrRegistro(Negocios,1,'SUCURSAL_CENTRO.CSV');
  //Ordenar arreglo intercambiar valor por dim
    listar(Negocios);
    write('ordenado - --------------------------------------------------------');
    ordenArrSeCod(Negocios,30);
    listar(Negocios);
  //convierte a .dat siguiendo las restricciones de caducidad y de alta
  arrAdat(Negocios, 'INVENTARIO.DAT');
end.