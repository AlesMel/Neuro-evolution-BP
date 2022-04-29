%muta1 - adit�vna mut�cia 1 g�nu s rovnomern�m rozdelen�m pravdepodobnosti
%
%	Charakteristika:
%	Funkcia zmutuje popul�ciu re�azcov s intenzitou �mernou parametru 
%	rate (z rozsahu od 0 do 1). Mutovan� je jeden g�n v ka�dom jedincovi. 
%   Mut�cie vznikn� pripo��tan�m alebo odpo��tan�m 
%	n�hodn�ch ��sel ohrani�en�ch ve�kost� k p�vodn�m hodnot�m g�nov celej 
%   Absol�tne hodnoty pr�pustn�ch ve�kost� 
%	adit�vnych mut�ci� s� ohrani�en� hodnotami vektora Amp. Po tejto oper�cii 
%	s� e�te v�sledn� hodnoty g�nov ohrani�en� (saturovan�) na hodnoty prvkov 
%	matice Space. Prv� riadok mat�ce ur�uje doln� ohrani�enia a druh� riadok 
%	horn� ohrani�enia jednotliv�ch g�nov. 
%
%
%	Syntax: 
%
%	Newpop=muta1(Oldpop,Amp,Space)
%
%	       Newpop - nov�, zmutovan� popul�cia
%	       Oldpop - star� popul�cia
%	       Amp    - vektor ohrani�en� pr�pustn�ch adit�vnych hodn�t mut�ci�
%	       Space  - matica obmedzen�, ktorej 1.riadok je vektor  minim�lnych a 2.  
%	                riadok je vektor maxim�lnych pr�pustn�ch mutovan�ch hodn�t
%
% I.Sekaj, 1/2020

function[Newpop]=muta1(Oldpop,Amps,Space)

[lpop,lstring]=size(Oldpop);

Newpop=Oldpop;

for r=1:lpop
s=ceil(rand*lstring);
Newpop(r,s)=Oldpop(r,s)+(2*rand-1)*Amps(s);
if Newpop(r,s)<Space(1,s) Newpop(r,s)=Space(1,s); end
if Newpop(r,s)>Space(2,s) Newpop(r,s)=Space(2,s); end
end

