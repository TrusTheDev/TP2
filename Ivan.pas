
Program HellyeahSimulator;
uses SysUtils;




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

//Esto da asco también
procedure cadenAfecha(var Fecha: tFecha; aux: String);
var
 i: Integer;
 c: char;
 strNumber: String;
 slash: Integer
begin
  strNumber:= '';
  slash := 0
  for i := 1 to Length(aux) do
  begin
    c:= aux[i];
    strNumber := strNumber + c;
    if c = '/' then strNumber := '', slash := slash++;
    case i of
    2: Fecha.day := StrToInt(strNumber);
    5: Fecha.month := StrToInt(strNumber);
    8: Fecha.year := StrToInt(strNumber)
    end;
  end;
end;
    
function cadenAlogico(aux: String):boolean;
begin
  cadenAlogico := aux = 'SI';
end;


procedure CSVaRegistro(var Negocio: tRegNegocio; RelativePath: String);
var
FileHandler: Text;
aux: String;
c: char;
i: Integer;

begin
  i := 1;
  c:= 'A';
  Assign(FileHandler, RelativePath);
  Reset(FileHandler);
  While not EoF(FileHandler) do
  begin
    //Esta seccion es una verga.
    aux := '';
    c := 'A';
      While  (c <> ',') and (not EOLn(FileHandler)) do
      begin
      Read(FileHandler,c);
      aux := aux + c
      end;
      if(c = ',') then Delete(aux, Length(aux), 1);
      

    case i of
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
      
      i:= i + 1;
  end;
  Close(FileHandler)
end;



var
Fecha: tFecha;
Negocio: tRegNegocio;
{ Program to demonstrate the Read(Ln) function. }
begin
  //CSVaRegistro(Negocio,'SUCURSAL_CENTRO.CSV');
  cadenAfecha(Fecha, '02/09/2025');
  Write(Fecha.year);
  
  
end.