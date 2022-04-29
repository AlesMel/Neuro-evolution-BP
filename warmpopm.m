% warmpopm - zohreje popul·ciu, n·sobÌ maticu popul·cie n·hodn˝mi
% ËÌslami s veækosùou max. 1+alfa
%
%	Description:
%	
%
%	Syntax: 
%
%	Newpop=warmpopm(Oldpop,alfa)
%
%	       Newpop - new warmed population
%	       Oldpop - old population
%	       alfa   - warm up intensity, 0 =< alfa =< 1
%

% I.Sekaj, 8/2021

function[Newpop]=warmpopm(Oldpop,alfa)

[lpop,lstring]=size(Oldpop);

M=(2*rand(lpop,lstring)-1)*alfa+ones(lpop,lstring);
Newpop=Oldpop.*M;
