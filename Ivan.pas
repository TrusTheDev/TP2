
Program HellyeahSimulator;

Procedure leerCSV(RelativePath: String);
Var S : String;
    C : Char;
    F : File of char;

//Leer csv por pantalla caracter por caracter
begin
  Assign (F,'RelativePath');
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


procedure CSVaRegistro(RelativePath: String);
var
FileHandler: File of char;
aux: String;
c: char;
i: Integer;
Type
tFecha = Record
  day: Integer;
  month: Integer;
  year: Integer
end;
Negocio = Record
  Seccion: String;
  Codigo: Integer;
  Nombre: String;
  Stock: Integer;
  Precio: Double;
  FechaAdq: tFecha;
  FechaUv: tFecha;
  FechaCad: tFecha;
  alta: boolean
end;
begin
  i := 1;
  c:= 'A';
  Assign(FileHandler, RelativePath);
  While not EoF(FileHandler) do
  begin
    aux := '';
    Read(FileHandler,c);
      While  c <> ',' do
      aux := aux + c;
      
    case i of
      1: Negocio.Seccion := aux;
      2: Negocio.Codigo := aux; 
      3: Negocio.Nombre := aux;
      4: Negocio.Stock := aux;
      5: Negocio.Precio := aux;
      6: Negocio.FechaAdq := aux;
      7: Negocio.FechaUv := aux;
      8: Negocio.FechaCad := aux;
      9: Negocio.alta := aux
      end;
      i:= i + 1;
  end;
  
end;



{ Program to demonstrate the Read(Ln) function. }
begin
leerCSV('SUCURSAL_CENTRO.CSV');
end.