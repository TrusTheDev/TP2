Program Example50;

{ Program to demonstrate the Read(Ln) function. }

Var S : String;
    C : Char;
    F : File of char;

//Leer csv por pantalla caracter por caracter
begin
  Assign (F,'SUCURSAL_CENTRO.CSV');
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
end.