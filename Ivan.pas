
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
  day: Integer;
  month: Integer;
  year: Integer
end;
tRegNegocio = Record
  Seccion: String;
  Codigo: Integer;
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
      //En los valores nulos pascal devuelve 0, es valido esto?
      //Linda ese casting eh
      0: Fecha.day := StrToInt(IntToStr(Fecha.day) + strNumber);
      1: Fecha.month := StrToInt(IntToStr(Fecha.month) + strNumber);
      2: Fecha.year := StrToInt(IntToStr(Fecha.year) + strNumber);
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
          2: Negocio.Codigo := StrToInt(aux); 
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
  linesCount := getFileLinesCount(RelativePath);
  for i:=1 to linesCount do
    begin
      getFileLine(LineRegister,i,RelativePath);
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
begin
  if (articuloBaja(Negocio)) or (articuloVencido(Negocio)) then
    articuloValido := false
  else;
    articuloValido := true;
end;

procedure arrToDat(Negocios: ArrRegNegocio; FilePath: String);
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

var
Negocio: tRegNegocio;
Negocios: ArrRegNegocio;
begin
  //Negocio de prueba;
  //Negocio.Seccion := 'Trusty almacen'; Negocio.Codigo := 10; Negocio.Nombre := 'Pochoclos'; Negocio.Stock := 15; Negocio.Precio := 1500; cadenAfecha(Negocio.FechaAdq, '02/09/2011'); cadenAfecha(Negocio.FechaUv, '01/03/2025'); cadenAfecha(Negocio.FechaCad, '01/09/2011'); Negocio.alta := false; 
  
  //crear arreglo del csv
  CSVaArrRegistro(Negocios,1,'SUCURSAL_CENTRO.CSV');
  //convierte a .dat siguiendo las restricciones de caducidad y de alta
  arrToDat(Negocios, 'INVENTARIO.DAT');
end.