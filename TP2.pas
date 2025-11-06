Program BitMarket;
uses SysUtils;

Type
tFecha = Record
  day: Integer;
  month: Integer;
  year: Integer
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

procedure cadenAfecha(var Fecha: tFecha; aux: String);
(* Que hace: Recibe una cadena de fecha en formato DD/MM/YYYY y devuelve un tipo tfecha
  Precondiciones: Fecha = F, aux = A Fecha perteneciente al tipo tFecha y aux con formato: DD/MM/YYYY.
  Poscondiciones: Fecha = F'
*)
var
 i: Integer;
 strNumber: String;
 slash: Integer;
begin
  slash := 0;
  strNumber:= '';
  for i := 1 to Length(aux) do
  begin
    strNumber := aux[i];
    if strNumber = '/' then 
    begin
      strNumber := '';
      slash := slash + 1;
    end; 

    case slash of
      0: Fecha.day := StrToInt(IntToStr(Fecha.day) + strNumber);
      1: Fecha.month := StrToInt(IntToStr(Fecha.month) + strNumber);
      2: Fecha.year := StrToInt(IntToStr(Fecha.year) + strNumber);
    end;
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


function getFileLinesCount(FilePath: String): Integer;
//Obtiene la cantidad de lineas de un archivo
(*  Que hace: cuenta la cantidad de lineas de un archivo.
    precondicones: FilePath = F y el directorio debe existir.
    poscondiciones: getFileLinesCount = n
*)
var
  FileText: Text;
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
Procedure getFileLine(var tempVar2: String; index: Integer; RelativePath: String);
//obtiene una linea dada por el bucle for, dios sabe por que esto funciona así.
(*  Que hace: obtiene una linea dado de un archivo dado
    precondicones: tempVar2 = T, index = I, RelativePath = R.
    poscondiciones: tempVar2 = T'
*)
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
procedure CSVaArrRegistro(var Negocios: ArrRegNegocio; var dim: Integer;RelativePath: String);
//Convierte un CSV a un arreglo de registros.
(*  Que hace:
    precondicones:
    poscondiciones:
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
(*  Que hace:
    precondicones:
    poscondiciones:
*)
var
  fechaAdq: tFecha;
  fechaCad: tFecha;
  vencido: boolean;
begin
  fechaAdq := Negocio.fechaAdq;
  fechaCad := Negocio.fechaCad;

  if (fechaAdq.year > fechaCad.year) then
    vencido := true
  else if (fechaAdq.year < fechaCad.year) then
    vencido := false
  else if (fechaAdq.month > fechaCad.month) then
    vencido := true
  else if (fechaAdq.month < fechaCad.month) then
    vencido := false
  else if (fechaAdq.day > fechaCad.day) then
    vencido := true
  else
    vencido := false;
  articuloVencido := vencido;
end;

function articuloValido(Negocio: tRegNegocio): boolean;  
//Verifica si un articulo es valido.
(*  Que hace:
    precondicones:
    poscondiciones:
*)
begin
  if (Negocio.alta) or (articuloVencido(Negocio)) then
    articuloValido := false
  else;
    articuloValido := true;
end;

procedure arrToDat(Negocios: ArrRegNegocio; FilePath: String);
//convierte un arreglo ordenado de negocios a un .dat dado
(*  Que hace:
    precondicones:
    poscondiciones:
*)
var
  datHandler: file of tRegNegocio;
  i: integer;
begin
  
  assign(datHandler, FilePath);
  if not FileExists(FilePath) then
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
//Ordena por seccion y codigo, parte del quicksort
(*  Que hace:
    precondicones:
    poscondiciones:
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
(*  Que hace:
    precondicones:
    poscondiciones:
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
//ordena el arreglo de negocios dado por Seccion y codigo.
(*  Que hace:
    precondicones:
    poscondiciones:
*)
begin
  Quicksort(Negocios,1, dim);
end;

procedure listar(Negocios: ArrRegNegocio; dim: integer);
(* que hace: itera y muestra la seccion y codigo de un arreglo de negocios dado.
    solamente para testear.
    precondiciones: Negocios = N, dim = D; [1..D] perteneciente al rango de ArrRegNegocio.
    poscondiciones: ninguna.
*)
var
i: integer;
begin
  for i:=1 to dim do 
  begin
    Writeln(Negocios[i].seccion);
    Writeln(Negocios[i].codigo);
  end;
end;
//--------------------------------------------------- Inicio del algoritmo ---------------------------------------------------.

var
Negocio: tRegNegocio;
Negocios: ArrRegNegocio;
dim: integer;

begin
    dim := 1;
    //levanto el csv a un arreglo de registros.
    CSVaArrRegistro(Negocios,dim,'SUCURSAL_CENTRO.CSV');
    listar(Negocios, dim);
    //ordeno el arreglo por seccion y codigo.
    ordenArrSeCod(Negocios,dim);
    listar(Negocios, dim);
    //convierto el arreglo ordenado a .dat
    arrToDat(Negocios, 'INVENTARIO.DAT');
end.