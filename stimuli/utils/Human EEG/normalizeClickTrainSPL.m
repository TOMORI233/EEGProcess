function Amp2 = normalizeClickTrainSPL(ISI1, ISI2, Amp1, ratioType)
% [f1, Pow1, P1] = mFFT(wave1, fs);
% [f2, Pow2, P2] = mFFT(wave2, fs);
% idx1 = f1 > 25;
% idx2 = f2 > 25;
% 
% SPL1 = 10*log10(sum(10.^(3.5 * Pow1(idx1)/10)));
% SPL2 = 10*log10(sum(10.^(4 * Pow2(idx2)/10)));
% SPL1 = 10*log10(3.5);
% SPL2 = 10*log10(3.5 * sqrt(4/3.5));
% SPL2 - SPL1
% 
% syms x
% eqn = log10(sum(P1(idx1))) == log10(x * sum(P2(idx2)));
% S = solve(eqn,x,"Real",true);
% ratio = double(S(S>0));
% 
% [f3, Pow3, P3] = mFFT(ratio * wave2, fs);
% idx3 = f3 > 25;
% SPL3 = 10*log10(sum(10.^(Pow3(idx3)/10)));
% if roundn(SPL3, -3) == roundn(SPL1, -3)
%     Amp2 = Amp1 * ratio;
%     if Amp2 > 1
%         error("the amp should not more than 1 !");
%     end
% else
%     error("sth wrong happens!");
% end
switch ratioType
    case 1 % normal
        Amp2 = ISI2 ./ ISI1 * Amp1;
    case 2 % sqrt
        Amp2 = Amp1 .* sqrt(ISI2 ./ ISI1);
end

end