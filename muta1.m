%muta1 - aditívna mutácia 1 génu s rovnomernım rozdelením pravdepodobnosti
%
%	Charakteristika:
%	Funkcia zmutuje populáciu reazcov s intenzitou úmernou parametru 
%	rate (z rozsahu od 0 do 1). Mutovanı je jeden gén v kadom jedincovi. 
%   Mutácie vzniknú pripoèítaním alebo odpoèítaním 
%	náhodnıch èísel ohranièenıch ve¾kostí k pôvodnım hodnotám génov celej 
%   Absolútne hodnoty prípustnıch ve¾kostí 
%	aditívnych mutácií sú ohranièené hodnotami vektora Amp. Po tejto operácii 
%	sú ešte vısledné hodnoty génov ohranièené (saturované) na hodnoty prvkov 
%	matice Space. Prvı riadok matíce urèuje dolné ohranièenia a druhı riadok 
%	horné ohranièenia jednotlivıch génov. 
%
%
%	Syntax: 
%
%	Newpop=muta1(Oldpop,Amp,Space)
%
%	       Newpop - nová, zmutovaná populácia
%	       Oldpop - stará populácia
%	       Amp    - vektor ohranièení prípustnıch aditívnych hodnôt mutácií
%	       Space  - matica obmedzení, ktorej 1.riadok je vektor  minimálnych a 2.  
%	                riadok je vektor maximálnych prípustnıch mutovanıch hodnôt
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

