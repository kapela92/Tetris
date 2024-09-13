program TETRIS;
uses crt,wavplay2;

const POZX_O=15;
      POZY_O=6;
      ROZX_O=12; 
      ROZY_O=17;
      KOLOR_PL=blue; 
      KOLOR_F=yellow;
      TLO=black; 
      TLO_RAMKI=red;
      KOLOR_RAMKI=yellow;
      CZAS=9;
      LOKAL_HISCORE='C:\WINDOWS\TETscore.tab';
type hiscore=record
             nazwa:string[10];
             punkty:integer;
             end;
     score_tab=array[1..10] of hiscore;
var f:array[1..23,1..4] of string;
    pl:array[1..ROZX_O,1..ROZY_O]of char;
    rozf_x:array[1..23]of byte;
    rozf_y:array[1..23]of byte;
    koniec:boolean;
    kolor_kl:byte;
    punkty:integer;
    czas_spa,a:byte;
    licz_linie:word;
    dzwiek:boolean;
    licznik2:integer;
     xx,yy,x,y,klik:integer;
    licznik:integer;
    pozycja:byte;
    aktywny:boolean;
    plik:file of score_tab;
    score:score_tab;
    pseudo:string;
	pomocnicza:char;
    pomocnicza2:integer;
	licz_km,licz,licz2:integer;
    strona,zlicz_poziom,licz_obroty:byte;
	
	
label 1;	


PROCEDURE okno(a,b,c,d,k,t:byte; y,x:string);
begin
   window(a,b,c,d);
   begin
   textattr:=16*t+k;
   clrscr;
   writeln;
   writeln(y);
   writeln(x);
   end;
end;
 	PROCEDURE resetscr;
begin
window(1,1,40,25) ;
textattr:=16*black+WHITE;
clrscr;
end;

procedure zerujmysz; assembler;
asm
   mov ax, 0004h
   mov cx, 0
   mov dx, 0
   int 33h
end;


PROCEDURE wezmysz(var x,y,klik:integer);
var temp1,temp2,temp3:word;
begin
   asm
      mov ax, 0003h
      int 33h
      mov temp1, bx
      mov temp2, cx
      mov temp3, dx
   end;
   klik:=temp1;
   x:=temp2;
   y:=temp3;
end;

procedure pokazmysz; assembler;
asm
   mov ax, 0001h
   int 33h
end;

Procedure DefineHorRange(Min, Max :Integer); Assembler;
Asm
    mov ax, 0007h
    mov cx, Min
    mov dx, Max
    int 33h
End; 

Procedure DefineVerRange(Min, Max :Integer); Assembler;
Asm
    mov ax, 0008h
    mov cx, Min
    mov dx, Max
    int 33h;
End; 

Procedure myszobszar(X1, Y1, X2, Y2 :Integer);
Begin
DefineHorRange(X1,X2);
DefineVerRange(Y1,Y2);
End          ;

Procedure BMPOpen (ax,ay:word; sciezka:string);
Type
 TNaglowek=
   Record
   bfType :             Word;
   bfSize :             LongInt;
   bfReserved :         LongInt;
   bfOffBits :          LongInt;
   biSize :             LongInt;
   biWidth :            LongInt;
   biHeight :           LongInt;
   biPlanes :           Word;
   biBitCount :         Word;
   biCompression :      LongInt;
   biSizeImage :        LongInt;
   biXPelsPerMeter :    LongInt;
   biYPelsPerMeter :    LongInt;
   biClrUsed :          LongInt;
   biClrImportant :     LongInt;
  End;
Var
   PlikNaglowek: file of Tnaglowek;
   Naglowek:Tnaglowek;
   bitmapa:file of byte;
   z,a:byte;
   b,g,r:byte;
   x,y:integer;
   kolor:byte;
   mode:word;
   
begin

   assign (PlikNaglowek,sciezka);      {skojarzenie z plikiem}
   reset (PlikNaglowek);                     {otwarcie do odczytu}
   read (PlikNaglowek,Naglowek);      {wczytanie nag≥Ûwka   }
{-------------------------------------------------------------------}
   assign (bitmapa,sciezka);
   reset (bitmapa);
asm                                  {w≥πczenie trybu graficznego}
   mov ax,13h
   int 10h
end;
for x:=1 to 54 do read (bitmapa,z);     {pominiÍcie nag≥Ûwka}
for x:=0 to 255 do begin               {wczytanie palety kolorÛw}
   read (bitmapa,b,g,r,z);                       {wczytanie kolorÛw BGR i pominiÍcie pustego bajtu(a)}
   port[$3c8]:=x;                                {port $3c8 oczekuje na sk≥adowe dla koloru x}
   port[$3c9]:=r div 4;                          {przesy≥amy}
   port[$3c9]:=g div 4;                          {te}
   port[$3c9]:=b div 4;                          {sk≥adowe}
end;                                             {mamy gotowπ paletÍ}
                                         
for y:=Naglowek.biHeight-1 downto 0 do        {a teraz wczytujemy kolory}
for x:=0 to Naglowek.biWidth-1  do
begin
   read (bitmapa,kolor);
   mem[$A000:y shl 8+ y shl 6 + x+ay shl 8 +ay shl 6+ax]:=kolor;
end;

init('xc.wav');
play;

end;



{********************************************************}
{********************************************************}
{****************BONUS************SAMOCHODIK*************}
{********************************************************}

procedure menu;
begin
 window(1,1,15,25);
 textattr:=(16*10);
 clrscr;
 window(25,5,55,7);
 textattr:=(16*10);
 clrscr;
 gotoxy(11,2);
 write('B O N U S ');
 window(25,10,55,15);
 textattr:=(16*10);
 clrscr;
 gotoxy(7,2);
 write('S T E R O W A N I E');
 gotoxy(6,4);
 write('<- (prawo)  (lewo) ->');
 window(30,21,50,23);
 textattr:=(16*10);
 clrscr;
 gotoxy(4,2);
 write('Wcisni enter...');
 window(65,1,80,25);
 textattr:=(16*10);
 clrscr;
end;

{************************************************}

procedure samochud_lewo;
var
i,i1,x1,x2,y1,y2,t1,t2,r1:integer;
begin
 y1:=23;
 x2:=32;
 y2:=24;
 for i:=1 to 5 do
 begin
  window(26,y1,x2,y2);
  textattr:=(16*12);
  clrscr;
  y1:=y1-1;
  x2:=x2-1;
  y2:=y2-1;
 end;
 r1:=21;
 t1:=23;
 t2:=24;
 for i1:=1 to 5 do
 begin
  window(r1,t1,26,t2);
  textattr:=(16*12);
  clrscr;
  r1:=r1+1;
  t1:=t1-1;
  t2:=t2-1;
 end;
  window(25,19,26,20);
 textattr:=(16*12+14);
 write(#223);
 window(28,19,28,20);
 textattr:=(16*12+14);
 write(#223);
 window(25,20,28,20);
 textattr:=(16*9);
 clrscr;
 window(23,23,30,23);
 textattr:=(16*9);
 clrscr;
 window(22,24,25,24);
 textattr:=(16*12+14);
 write(#220);
 window(31,24,32,24);
 textattr:=(16*12+14);
 write(#220);
end;

{****************************************************************}

procedure samochud_prawo;
var
i,i1,x1,x2,y1,y2,t1,t2,r1:integer;
begin
 y1:=23;
 x2:=59;
 y2:=24;
 for i:=1 to 5 do
 begin
  window(53,y1,x2,y2);
  textattr:=(16*12);
  clrscr;
  y1:=y1-1;
  x2:=x2-1;
  y2:=y2-1;
 end;
 r1:=48;
 t1:=23;
 t2:=24;
 for i1:=1 to 5 do
 begin
  window(r1,t1,53,t2);
  textattr:=(16*12);
  clrscr;
  r1:=r1+1;
  t1:=t1-1;
  t2:=t2-1;
 end;
 window(52,19,52,20);
 textattr:=(16*12+14);
 write(#223);
 window(55,19,55,20);
 textattr:=(16*12+14);
 write(#223);
 window(52,20,55,20);
 textattr:=(16*9);
 clrscr;
 window(50,23,57,23);
 textattr:=(16*9);
 clrscr;
 window(49,24,50,24);
 textattr:=(16*12+14);
 write(#220);
 window(58,24,59,24);
 textattr:=(16*12+14);
 write(#220);
end;

{*****************************************************************}

procedure przeszkody;
var
d,x,y,x2,y2:byte;
label miejsce;
begin
  licz:=licz-1;
  licz2:=licz2+1;
  miejsce:
  if licz=27 then
  strona:=random(3);
  if strona-1=0 then   {lewo}
   begin
    if(licz2+2<=24)then
	begin
     window(licz,licz2,38,licz2+2);
     textattr:=(16*13);
     clrscr;
	end;
    if licz2>=11 then
     begin
      window(licz,licz2-1,38,licz2);
      textattr:=(16*8);
      clrscr;
     end;
   end;
  if strona-1=1 then   {prawo}
   begin
    if(licz2+2<=24)then
	begin
     window(43,licz2,licz2+43,licz2+2);
     textattr:=(16*13);
     clrscr;
	end;
    if licz2>=11 then
     begin
      window(43,licz2-1,licz2+43,licz2);
      textattr:=(16*8);
      clrscr;
     end;
   end;
  if strona=0 then
  goto miejsce;
  if licz=12 then
   begin
    licz:=28;
    licz2:=9;
   end;
end;

{*****************************************************************}

procedure game_over;
var
a:byte;
 begin
  window(1,1,80,25);
  textattr:=(16*0);
  clrscr;
  window(20,6,60,17);
  textattr:=(16*4);
  clrscr;
  window(30,9,50,14);
  textattr:=(16*10);
  clrscr;
  gotoxy(5,4);
  write('GAME OVER');
  a:=14;
  repeat
  a:=a+1;
  {window(30,9,50,14);}
  gotoxy(a,4);
  write('.');
  delay(1000);
  until a=17;
 end;

{********************************************************************}

procedure droga;
var
x1,x2,y1,y2,i,a,b,x,y,v:integer;
z:char;
begin
 window(1,1,80,25);
 textattr:=(16*0);
 clrscr;
 window(1,1,80,10);
 textattr:=(16*9);
 clrscr;
 window(1,10,80,25);
 textattr:=(16*8);
 clrscr;
 {samochud_prawo;}
 samochud_lewo;
 x2:=10;
 y2:=25;
 for i:=1 to 16 do
 begin
  window(1,10,x2,y2);
  textattr:=(16*10);
  clrscr;
  x2:=x2+1;
  y2:=y2-1;
 end;
 x1:=55;
 y1:=10;
 for a:=1 to 16 do
 begin
  window(x1,10,80,y1);
  textattr:=(16*10);
  clrscr;
  x1:=x1+1;
  y1:=y1+1;
 end;
 window(69,11,80,14);
 textattr:=(16*12);
 clrscr;
 window(71,12,78,13);
 textattr:=(16*0);
 clrscr;
 window(40,10,41,25);
 textattr:=(16*15);
 clrscr;
 licznik:=0;
 repeat   {poczatek petli}
  if ((licz_km>1) and (licz_km<18))
  or ((licz_km>19) and (licz_km<36))
  or ((licz_km>37) and (licz_km<54))
  or ((licz_km>55) and (licz_km<72))
  or ((licz_km>73) and (licz_km<90)) then
  przeszkody;
  if (strona-1=0) and (z=#75) and (licz2+2>=18) then
  begin
   game_over;
   break;
  end;
  if (strona-1=1) and (z=#77) and (licz2+2>=18) then
  begin
   game_over;
   break;
  end;
   x:=10;
   y:=11;
  for b:=1 to 6 do
  begin
   if keypressed then
   begin
     z:=readkey;
     if (z=#77) then
     begin
      window(17,19,32,24);
      textattr:=(16*8);
      clrscr;
	  clrscr;
      samochud_prawo;
     end;
     if (z=#75) then
     begin
      window(48,19,59,24);
      textattr:=(16*8);
      clrscr;
	  clrscr;
      samochud_lewo;
     end;
   end;
   if(zlicz_poziom<=7)then
   delay(50-(zlicz_poziom*6))
   else
   delay(8);
   if b>1 then
   begin
    window(40,x-1,41,y-1);
    textattr:=(16*15);
    clrscr;
    window(40,24,41,25);
    textattr:=(16*15);
    clrscr;
   end;
   if b>2 then
   begin
    window(40,x-2,41,y-2);
    textattr:=(16*15);
    clrscr;
   end;
   if b>3 then
   begin
    window(40,x-3,41,y-3);
    textattr:=(16*15);
    clrscr;
   end;
   if b>4 then
   begin
    window(40,x-4,41,y-4);
    textattr:=(16*15);
    clrscr;
   end;
   if b>5 then
   begin
    window(40,x-5,41,y-5);
    textattr:=(16*15);
    clrscr;
   end;
   window(40,x,41,y);
   textattr:=(16*8);
   clrscr;
   window(40,x+1,41,y+4);
   textattr:=(16*15);
   clrscr;
   window(40,x+5,41,y+5);
   textattr:=(16*8);
   clrscr;
   window(40,x+6,41,y+9);
   textattr:=(16*15);
   clrscr;
   window(40,x+10,41,y+9);
   textattr:=(16*8);
   clrscr;
   if b=1 then
   begin
    Window(40,x+15,41,y+15);
    textattr:=(16*8);
    clrscr;
   end;
   x:=x+1;
   y:=y+1;
  end;
   licz_obroty:=licz_obroty+1;
   if(licz_obroty mod 2=0)then
   licz_km:=licz_km+1;
   window(72,12,78,13);
   textattr:=(16*0+15);
   clrscr;
   gotoxy(1,2);
   write(licz_km,' Km');
until licz_km=100;  {koniec pÍtli}
end;


{********************************************************}
{********************************************************}
{****************KONIEC***BUNUSU***SAMOCHODZIK***********}
{********************************************************}

	
	
procedure wpisz(pozx,pozy,k_tlo,k_tekst,dlg:byte;var lan2:string);
var a,poz_k,rozmiar:shortint;
    kod:shortint;
    znak:char;
    lan:string;
begin
textcolor(k_tekst);textbackground(k_tlo);
a:=0;
repeat   
  gotoxy(pozx+a,pozy);write(' ');inc(a);
until a=dlg+1;

gotoxy(pozx,pozy);
poz_k:=0;

lan:=lan2;
poz_k:=length(lan);

repeat
  rozmiar:=length(lan);
  if poz_k>rozmiar then poz_k:=rozmiar;
  if poz_k<0 then poz_k:=0;            
  gotoxy(pozx,pozy);write(lan,' ');    
  gotoxy(pozx+poz_k,pozy);             
  znak:=readkey;
  if znak=#13 then kod:=-1;{enter}
  if znak=#27 then kod:=-2;{escape}
  if znak=#8 then begin delete(lan,poz_k,1);dec(poz_k); end;

  if (znak>#64)and(znak<#91)or(znak>#94)and(znak<#123)and(rozmiar<dlg)or(znak=#32) then
  begin
    insert(znak,lan,poz_k+1);
    inc(poz_k);
  end;

  if znak=#0 then
  begin
    znak:=readkey;
    case znak of
      #83:begin delete(lan,poz_k+1,1);end;{delete}
      #79:poz_k:=length(lan);{end}
      #71:poz_k:=0;{home}
      #75:dec(poz_k);{w lewo}
      #77:inc(poz_k);{w prawo}
    end;
  end;
until (kod=-1) or (kod=-2);

if kod=-1 then lan2:=lan;

end;



procedure ukryj_kursor; assembler;
asm
mov ah,01h
mov ch,10h
mov cl,00h
int 10h
end;

procedure pokaz_kursor; assembler;
asm 
mov ah,01h
mov ch,07h
mov cl,07h
end;

procedure ramka(pozx_pl,pozy_pl,rozx_pl,rozy_pl:byte);
var x,y:byte;
begin
x:=0;y:=0;
textbackground(TLO_RAMKI);
textcolor(KOLOR_RAMKI);
for x:=0 to rozx_pl-1 do 
begin
  gotoxy(pozx_pl+x,pozy_pl+rozy_pl);write(chr(205));
end;
for y:=0 to rozy_pl-1 do 
begin
  gotoxy(pozx_pl-1,pozy_pl+y);write(chr(186));
  gotoxy(pozx_pl+rozx_pl,pozy_pl+y);write(chr(186));
end;
{rysowanie katow}
gotoxy(pozx_pl-1,pozy_pl+rozy_pl);write(chr(200));
gotoxy(pozx_pl+rozx_pl,pozy_pl+rozy_pl);write(chr(188));
end;

procedure scroll(var aktywny:boolean;rozmiar,px,py:byte;ped:word;text:string);
var l:word;

begin
if aktywny=true then
begin
  inc(licznik);
  if licznik=ped then
  begin
    licznik:=0;
    inc(pozycja);if pozycja>=length(text) then pozycja:=1;
  end;
  l:=0;repeat;inc (l);text:=' '+text;until l=rozmiar+2;text:=text+' ';
  gotoxy(px,py);textbackground(TLO);
  write(copy(text,pozycja,rozmiar));

end;
end;


procedure figury;
begin
fillchar(f,sizeof(f),#0);
fillchar(pl,sizeof(pl),#32);

rozf_x[1]:=1;rozf_y[1]:=4;
f[1,1]:=#219;   {#}
f[1,2]:=#219;   {#}
f[1,3]:=#219;   {#}
f[1,4]:=#219;   {#}

rozf_x[2]:=4;rozf_y[2]:=1;
f[2,1]:=#219+#219+#219+#219;{####}

rozf_x[3]:=2;rozf_y[3]:=2;
f[3,1]:=#219+#219;{##}
f[3,2]:=#219+#219;{##}

rozf_x[4]:=2;rozf_y[4]:=3;
f[4,1]:=#219+#219;{##}
f[4,2]:=' '+#219; { #}
f[4,3]:=' '+#219; { #}

rozf_x[5]:=3;rozf_y[5]:=2;
f[5,1]:=#219+#219+#219;{###}
f[5,2]:=#219;          {#}

rozf_x[6]:=2;rozf_y[6]:=3;
f[6,1]:=#219;      {#}
f[6,2]:=#219;      {#}
f[6,3]:=#219+#219; {##}

rozf_x[7]:=3;rozf_y[7]:=2;
f[7,1]:='  '+#219;     {  #}
f[7,2]:=#219+#219+#219;{###}

rozf_x[8]:=2;rozf_y[8]:=3;
f[8,1]:=' '+#219; { #}
f[8,2]:=#219+#219;{##}
f[8,3]:=#219;     {# }

rozf_x[9]:=3;rozf_y[9]:=2;
f[9,1]:=#219+#219;    {## }
f[9,2]:=' '+#219+#219;{ ##}

rozf_x[10]:=2;rozf_y[10]:=3;
f[10,1]:=#219;     {# }
f[10,2]:=#219+#219;{##}
f[10,3]:=' '+#219; { #}

rozf_x[11]:=3;rozf_y[11]:=2;
f[11,1]:=' '+#219+#219;    { ##}
f[11,2]:=#219+#219;{## }

rozf_x[12]:=3;rozf_y[12]:=2;
f[12,1]:=' '+#219;      { # }
f[12,2]:=#219+#219+#219;{###}

rozf_x[13]:=2;rozf_y[13]:=3;
f[13,1]:=' '+#219; { #}
f[13,2]:=#219+#219;{##}
f[13,3]:=' '+#219; { #}

rozf_x[14]:=3;rozf_y[14]:=2;
f[14,1]:=#219+#219+#219;{###}
f[14,2]:=' '+#219;      { # }

rozf_x[15]:=2;rozf_y[15]:=3;
f[15,1]:=#219;     {# }
f[15,2]:=#219+#219;{##}
f[15,3]:=#219;     {# }

rozf_x[16]:=2;rozf_y[16]:=3;
f[16,1]:=#219+#219;{##}
f[16,2]:=#219;     {#}
f[16,3]:=#219;     {#}

rozf_x[17]:=3;rozf_y[17]:=2;
f[17,1]:=#219;          {#}
f[17,2]:=#219+#219+#219;{###}

rozf_x[18]:=2;rozf_y[18]:=3;
f[18,1]:=' '+#219;  { #}
f[18,2]:=' '+#219;  { #}
f[18,3]:=#219+#219; {##}

rozf_x[19]:=3;rozf_y[19]:=2;
f[19,1]:=#219+#219+#219;{###}
f[19,2]:='  '+#219;     {  #}
rozf_x[20]:=2;rozf_y[20]:=3;
f[20,1]:=#219+#219;{##}
f[20,2]:=' '+#219; { #}
f[20,3]:=' '+#219; { #}

rozf_x[21]:=3;rozf_y[21]:=2;
f[21,1]:=#219+#219+#219;{###}
f[21,2]:=#219;          {#}

rozf_x[22]:=2;rozf_y[22]:=3;
f[22,1]:=#219;      {#}
f[22,2]:=#219;      {#}
f[22,3]:=#219+#219; {##}

rozf_x[23]:=3;rozf_y[23]:=2;
f[23,1]:=' '+' '+#219;  {  #}
f[23,2]:=#219+#219+#219;{###}

end;

procedure rysuj_figure(ktora,x,y:byte);
var px,py:byte;
    ciag:string;
begin
px:=0;py:=0;
textcolor(KOLOR_F);textbackground(KOLOR_PL);
for py:=1 to ROZY_O do
begin
  for px:=1 to ROZX_O do
  begin
    gotoxy(POZX_O-1+px,POZY_O-1+py);
    write(pl[px,py]);
  end;
end;
x:=x+POZX_O;y:=y+POZY_o;
textcolor(kolor_kl);
for py:=1 to 4 do
begin
  ciag:=f[ktora,py]+'     '; 
  for px:=1 to 4 do
  begin
    if ciag[px]=#219 then
    begin
      gotoxy(x+px-1,y+py-1);write(#219);
    end;
  end;
end;
end;

procedure wpiszF_plan(ktora,x,y:byte);{wpisuje figure do pamieci planszy}
var x1,y1:byte;
    ciag:string;
begin
x1:=0;y1:=0;
for y1:=1 to 4 do
begin
  ciag:=f[ktora,y1]+'     '; 
  for x1:=1 to 4 do
  begin
    if ciag[x1]=#219 then
    begin
      pl[x+x1,y+y1-1]:=#219;
    end;
  end;
end;

end;

function sprawdz_cal(ktora,x,y:byte):boolean;{spr czy pod figura nie ma juz innych}
var x1,y1:byte;
    spr:boolean;
begin
spr:=false;x1:=0;y1:=0;
repeat
  inc(y1);x1:=0;
  repeat
    inc(x1);
    if pl[x+x1,y+y1]=#219 then spr:=true;
  until (x1=rozf_x[ktora])or(spr=true);
until (y1=rozf_y[ktora])or(spr=true);
sprawdz_cal:=spr;
end;

function sprawdz_dol(ktora,x,y:byte):boolean;{spr czy pod figura nie ma innej}
var x1,y1:byte;
    ciag:string;
    spr:boolean;
begin
spr:=false;
x1:=0;y1:=0;
repeat
  inc(y1);x1:=0;
  ciag:=f[ktora,y1]+'     '; 
  repeat
    inc(x1);
    if ciag[x1]=#219 then
    begin
      if pl[x+x1,y+y1]=#219 then spr:=true;
    end;
  until(spr=true)or(x1=4);
until (spr=true)or(y1=4);
sprawdz_dol:=spr;
end;

function sprawdz_lewo(ktora,x,y:byte):boolean;{spr czy pod figura nie ma innej}
var x1,y1:byte;
    ciag:string;
    spr:boolean;
begin
spr:=false;
x1:=0;y1:=0;
repeat
  inc(y1);x1:=0;
  ciag:=f[ktora,y1]+'     ';
  repeat
    inc(x1);
    if ciag[x1]=#219 then
    begin
      if pl[x+x1-1,y+y1]=#219 then spr:=true;
    end;
  until(spr=true)or(x1=4);
until (spr=true)or(y1=4);
sprawdz_lewo:=spr;
end;

function sprawdz_prawo(ktora,x,y:byte):boolean;
var x1,y1:byte;
    ciag:string;
    spr:boolean;
begin
spr:=false;
x1:=0;y1:=0;
repeat
  inc(y1);x1:=0;
  ciag:=f[ktora,y1]+'     '; 
  repeat
    inc(x1);
    if ciag[x1]=#219 then
    begin
      if pl[x+x1+1,y+y1]=#219 then spr:=true;
    end;
  until(spr=true)or(x1=4);
until (spr=true)or(y1=4);
sprawdz_prawo:=spr;
end;

procedure zmien_figure(var ktora:byte;x,y:byte);
var z:boolean;
    k:byte;
begin
   z:=false;k:=ktora;
   if (k=1)and(z=false)then begin k:=2;z:=true;end;
   if (k=2)and(z=false)then begin k:=1;z:=true;end;
   if (k=4)and(z=false)then begin k:=5;z:=true;end;
   if (k=5)and(z=false)then begin k:=6;z:=true;end;
   if (k=6)and(z=false)then begin k:=7;z:=true;end;
   if (k=7)and(z=false)then begin k:=4;z:=true;end;
   if (k=8)and(z=false)then begin k:=9;z:=true;end;
   if (k=9)and(z=false)then begin k:=8;z:=true;end;
   if (k=10)and(z=false)then begin k:=11;z:=true;end;
   if (k=11)and(z=false)then begin k:=10;z:=true;end;
   if (k=12)and(z=false)then begin k:=13;z:=true;end;
   if (k=13)and(z=false)then begin k:=14;z:=true;end;
   if (k=14)and(z=false)then begin k:=15;z:=true;end;
   if (k=15)and(z=false)then begin k:=12;z:=true;end;
   if (k=16)and(z=false)then begin k:=17;z:=true;end;
   if (k=17)and(z=false)then begin k:=18;z:=true;end;
   if (k=18)and(z=false)then begin k:=19;z:=true;end;
   if (k=19)and(z=false)then begin k:=16;z:=true;end;
   if (k=20)and(z=false)then begin k:=21;z:=true;end;
   if (k=21)and(z=false)then begin k:=22;z:=true;end;
   if (k=22)and(z=false)then begin k:=23;z:=true;end;
   if (k=23)and(z=false)then begin k:=20;z:=true;end;

if (sprawdz_cal(k,x,y)=false)and(rozf_x[k]+x<=ROZX_O)and(rozf_y[k]+y<=ROZY_O) then ktora:=k;
end;

procedure klawisze(var x,y,ktora:byte);{pozwala na ruch figura}
var kl:char;
    l:longint;
    z:boolean;
begin
l:=0;z:=false;
repeat
  if keypressed then
  begin
    kl:=readkey;
    if kl='p'then readkey;
    if kl=#0 then
    begin
      kl:=readkey;
      case kl of
      #75:if (x>=1)and(sprawdz_lewo(ktora,x,y)=false) then dec(x);{w lewo}
      #77:if (rozf_x[ktora]+x<ROZX_O)and(sprawdz_prawo(ktora,x,y)=false) then inc(x);{w prawo}
      #72:zmien_figure(ktora,x,y);
      #80:begin
            inc(y);l:=74;
            if rozf_y[ktora]+y-1=ROZY_O then y:=ROZY_O-rozf_y[ktora];
             if sprawdz_dol(ktora,x,y)=true then y:=y-1;
          end;
      end;
    end;
  end;
  inc(l);
  delay(1);
until l=75;
end;

procedure spr_linie;
var x,y,x2,y2:byte;
    spr:boolean;
begin
y:=ROZY_O+1;
x:=ROZX_O+1;
repeat
  dec(y);spr:=true;x:=ROZX_O+1;
  repeat
    dec(x);
    if pl[x,y]<>#219 then spr:=false;
  until (x=1)or(spr=false);
  if spr=true then 
  begin
    
    y2:=y+1;punkty:=punkty+(5*(ROZY_O+1-y));
    repeat
      dec(y2);x2:=ROZX_O+1;
      repeat
        dec(x2);
        pl[x2,y2]:=pl[x2,y2-1]
      until x2=1;
    until y2=2;
    inc(y);
    inc(licz_linie);
    if licz_linie=6 then begin licz_linie:=1;czas_spa:=czas_spa-1;end;
    if czas_spa<2 then czas_spa:=2;
  end;
until y=1;
end;

procedure wyswietl_info(ktora2:byte);
begin
textcolor(white);textbackground(TLO);
gotoxy(3,10);write('Punkty:',punkty);
gotoxy(3,12);write('Poziom:',CZAS-czas_spa+1);
textcolor(white);
gotoxy(30,9);write('Nastepna:');

gotoxy(30,10);write('        ');{czysci pole pod nowa figure}
gotoxy(30,11);write('        ');
gotoxy(30,12);write('        ');
gotoxy(30,13);write('        ');
gotoxy(30,14);write('        ');
rysuj_figure(ktora2,18,5);
end;

procedure ruch;{tutaj toczy sie gra, gracz kieruje figurami, komp sprawdza i nalicza pkt}
var x,y,ktora,ktora2:byte;
    koniec_gry,nastepna:boolean;
    l:longint;
	
begin
zlicz_poziom:=CZAS-czas_spa+1;
  
ktora:=random(22)+1;{losuje pierwsza figure}
repeat
if(zlicz_poziom<CZAS-czas_spa+1)then
  begin
    textMode(c80);
	ukryj_kursor;
    licz_km:=0;
    licz:=28;
    licz2:=9;
    menu;
    readln;
    droga;
    delay(200);
	punkty:=punkty+licz_km;
    window(1,1,80,25);
    textattr:=(16*0);
    clrscr;
    zlicz_poziom:=CZAS-czas_spa+1;
    textmode(c40);
	ukryj_kursor;
	textcolor(white);
    gotoxy(15,2);
	write('T+E+T+R+I+S');
    ramka(POZX_O,POZY_O,ROZX_O,ROZY_O);
  end;

  x:=ROZX_O div 2;y:=0;{start lotu w polowie okna gry}
  nastepna:=false;{okresla czy zmienic figure}
  l:=0;
  ktora2:=random(22)+1;{losuje ktora nastepna figura}
  kolor_kl:=random(3)+3;{losuje kolor figury}
  if sprawdz_cal(ktora2,ROZX_O div 2,0)=true then koniec_gry:=true;{jesli nie ma miejsca na nowy klocek}
  punkty:=punkty+5;
  wyswietl_info(ktora2);
  repeat
    inc(l);{liczy czas do przesuniecia w dol}
    klawisze(x,y,ktora);
    rysuj_figure(ktora,x,y);{rusyje figure na ekranie}
    nosound;
    if l=czas_spa then begin l:=0;inc(y);if dzwiek=true then sound(0);end;{jesli juz przesunac w dol}
    if sprawdz_dol(ktora,x,y)=true then nastepna:=true;
    {sprawdzenie czy nie dotknelo dna}
    if rozf_y[ktora]+y-1=ROZY_O then nastepna:=true;
  until (nastepna=true)or(koniec_gry=true);
  wpiszF_plan(ktora,x,y);
  spr_linie;
  ktora:=ktora2;
   
until koniec_gry=true;
end;

procedure muzyka;
begin
  inc(licznik2);
  if licznik2=200 then sound(200);
  if licznik2=350 then nosound;
  if licznik2=450 then sound(200);
  if licznik2=700 then nosound;
  if licznik2=800 then sound(600);
  if licznik2=900 then sound(400);
  if licznik2=1100 then sound(300);
  if licznik2=1200 then sound(350);
  if licznik2=1400 then sound(400);
  if licznik2=1600 then sound(450);
  if licznik2=1700 then nosound;
  if licznik2=1800 then sound(500);
  if licznik2=1900 then nosound;
  if licznik2=1950 then sound(600);
  if licznik2=2000 then sound(500);
  if licznik2=2100 then sound(300);
  if licznik2=2200 then begin licznik2:=0;nosound;end;

end;

procedure pierwszy_ekran;
var kl:char;
    a,x,y,px,py,ktora:byte;
    ciag:string;
    l,l2,l3,l4:integer;
    tekst:string;
begin
pokazmysz;

clrscr;
textcolor(white);
gotoxy(3,2);write('T--E--T--R--I--S ');
tekst:='Program stworzony w kl.III Technikum Informatycznego przez Michala Kapele, Adama Kaczora i Mikolaja Janasa.';
l:=0;ktora:=0;
l2:=0;
l3:=0;
l4:=0;
pozycja:=0;
begin
zerujmysz; 
myszobszar(1,1,312,100);

 repeat
  delay(1); 
   
  inc(l);{jest to licznik przerwan}
  inc(l2);
  
  if dzwiek=true then muzyka;
  inc(l4);
  if (l4>=0)and(l4<80) then textcolor(white);    {blyski figur}
  if (l4>=80)and(l4<160) then textcolor(lightgreen);
  if (l4>=160)and(l4<240) then textcolor(green);
  if (l4>=240)and(l4<=320) then begin textcolor(lightgreen);if l4=320 then l4:=0;end;
  scroll(aktywny,17,2,20,200,tekst);
  if l=1000 then l:=0;
  if l=500 then{czyszczenie pola}
  begin
    inc(ktora);if ktora=20 then ktora:=1;
    for y:=1 to 11 do begin gotoxy(1,5+y);write('                   ');end;
  end;
  {rysowanie powiekszonych figur}
  if (l2>=0)and(l2<100) then textcolor(white);    {blyski figur}
  if (l2>=100)and(l2<200) then textcolor(lightblue);
  if (l2>=200)and(l2<300) then textcolor(blue);
  if (l2>=300)and(l2<=400) then begin textcolor(lightblue);if l2=400 then l2:=0;end;
  if ktora<17 then
  begin
    y:=0;
    for py:=1 to 4 do
      

	begin
      y:=y+2;x:=0;
      ciag:=f[ktora,py]+'     '; {petla sprawdza w poziomie czy nie ma #219}
      for px:=1 to 4 do
      begin
        x:=x+2;
        if ciag[px]=#219 then
        begin
          gotoxy(6+x,6+y);write(#219);
          gotoxy(6+x+1,6+y);write(#219);
          gotoxy(6+x,6+y+1);write(#219);
          gotoxy(6+x+1,6+y+1);write(#219);
        end;
     end;
    end;
  end;
  
  
   
   wezmysz(xx,yy,klik);

			  If ((xx>=8) and (xx<=80) and (yy>=24) and (yy<=36) and (klik=1))   Then kl:=#13;
			  If ((xx>=240) and (xx<=308) and (yy>=24) and (yy<=36) and (klik=1))  Then  kl:=#1;
			 
			  
    	  If ((xx>=240) and (xx<=312) and (yy>=60) and (yy<=76) and (klik=1))  Then koniec:=true;
			  If ((xx>=8) and (xx<=80) and (yy>=60) and (yy<=76) and (klik=1))  Then 
			  begin
			  if dzwiek=true then begin dzwiek:=false;nosound;end
			  else  dzwiek:=true;
			  end;
   
  if keypressed then {odczyt klawiszy}
  begin
    kl:=readkey;
    if (kl='q')or(kl=#27) then koniec:=true;
    if (kl='m')and(dzwiek=true)then begin dzwiek:=false;kl:=#0;nosound;end;
    if (kl='m')and(dzwiek=false)then begin dzwiek:=true;kl:=#0;end;
  
    end;
	pomocnicza:=kl;

  until (koniec=true)or(kl=#13)or(kl=#1);
end;end;

procedure zapisz_hiscore;
begin
  rewrite(plik);
  write(plik,score);
  close(plik);
end;

procedure laduj_hiscore;
var a:byte;
begin
  {$I-}{wylaczenie kontroli warunkow wejscia/wyjscia}
  reset(plik);
  {$I+}{wlaczenie}
  if IOResult=2 then begin rewrite(plik);write(plik,score);reset(plik);end;{jesli brak pliku}
  read(plik,score);
  close(plik);
end;

procedure sprawdz_hiscore;
var a,b:byte;
begin
  a:=0;
  repeat   {sprawdzenie czy pobito jakis rekord}
    inc(a);
  until (a=6)or(score[a].punkty<punkty);
  if a<>6 then
  begin
     b:=6;
     while b<>a do {przepisywanie wartosci hiscore o jedno nizej}
     begin
       dec(b);
       score[b].nazwa:=score[b-1].nazwa;
       score[b].punkty:=score[b-1].punkty;
     end;
     gotoxy(12,6);write('Jestes na ',a,' pozycji.');
     wpisz(16,12,yellow,red,10,pseudo);
     score[a].nazwa:=pseudo; {wpisanie nowego rekordu}
     score[a].punkty:=punkty;
     zapisz_hiscore;
  end;
end;

BEGIN


BMPOpen (1,1,'tetris.bmp');
textmode(c40);{ustawienie ekranu na roz 40x25}
ukryj_kursor;


koniec:=false;
dzwiek:=false;licznik2:=0;{wlaczona muzyka}
licznik:=0;pozycja:=0;aktywny:=true;{potrzebne do scrolla}



assign(plik,LOKAL_HISCORE);{przypisuje zmiennej plik PLIK TETscore.tab}
laduj_hiscore;{laduje HISCORE}

1:
repeat


pseudo:='';
  textbackground(tlo);
  resetscr;
  
  nosound;
  figury;
    okno(2,6,10,10,white,4,'','  START');
	okno(31,6,39,10,WHITE,4,'',' WYNIKI');
   okno(31,15,39,19,WHITE,4,'',' ZAKO—CZ');
   okno(2,15,10,19,white,4,#157,' DèWI K');
   
  okno(12,1,30,25,4,black,'','');
  
  pierwszy_ekran;
  
  
			
 clrscr;nosound;
  textcolor(white);
  

  if (pomocnicza=#13) then
  begin
  
  resetscr;
  gotoxy(15,3);write('T+E+T+R+I+S');
    punkty:=0;
    licz_linie:=1;{poziom 1 czas spadania to CZAS-1}
    czas_spa:=CZAS;
    randomize;
    textbackground(TLO);
    figury;
    ramka(POZX_O,POZY_O,ROZX_O,ROZY_O);
    ruch;
    textcolor(blink+green);
    textbackground(TLO);
	clrscr;
    gotoxy(16,4);write(' GAME  OVER!');delay(1000);
    sprawdz_hiscore;
	normvideo;
  end;

if pomocnicza=#1 then
begin
resetscr;
a:=0;
repeat
inc(a);
      gotoxy(17,6);write('HI-SCORE');
      gotoxy(12,7+a);write(a,'.',score[a].nazwa);
      gotoxy(27,7+a);write(score[a].punkty);

until a=5;

gotoxy(3,17);
writeln('Aby wroci do MENU wciúnij ENTER...') ;
readln;
  goto 1;
  end;
  until koniec=true;
nosound;
END.
