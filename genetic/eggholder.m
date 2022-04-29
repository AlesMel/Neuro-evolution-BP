% Test function 10 (Egg holder function)
% It is a multimodal function with optional number of input variables.
% The global optimum is:  x(i)= ; i=1...n ;  Fit(x)= ;
% -500 < x(i) < 500


function[Fit]=eggholder(Pop)


[lpop,lstring]=size(Pop);

for i=1:lpop
  G=Pop(i,:);
  Fit(i)=0;
  for j=1:(lstring-1)
    Fit(i)=Fit(i)-G(j)*sin(sqrt(abs(G(j)-(G(j+1)+47))))-(G(j+1)+47)*sin(sqrt(abs(G(j+1)+47+G(j)/2)));
  end;  
end;
