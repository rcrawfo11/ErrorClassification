function fitColeColeVariableEnd( dataStruct)

loadConstants;

magPhase = dataStruct.HEM005.sfb7.sfb72bis.magPhaseCalibRun10;

freqs = dataStruct.HEM011.sfb7.sfb72bis.frequencies;
startIndex = 15;
endIndex = 25;

for j = startIndex:endIndex
    fit = fitColeColeModelLSQFIT(freqs(1,1:j),magPhase(:,1:j),0,'');
    Re(j) = fit.Re;
    Ri(j) = fit.Ri;
    Cm(j) = fit.Cm;
    alpha(j) = fit.alpha;
end

%%
loadPlotDefaults
semilogx(freqs(startIndex:endIndex),Re(startIndex:endIndex),lineType,'LineWidth',lineWidth,'MarkerSize',markerSize);
hold(gca,'on');
semilogx(freqs(startIndex:endIndex),Ri(startIndex:endIndex),lineType,'LineWidth',lineWidth,'MarkerSize',markerSize);
semilogx(freqs(startIndex:endIndex),ri2rinf(Re(startIndex:endIndex), Ri(startIndex:endIndex)),lineType,'LineWidth',lineWidth,'MarkerSize',markerSize);
hold(gca,'off');
formatAxesByType(gca,'other');
legend('Re','Ri','Rinf');
xlabel('Frequency (Hz)')
ylabel('Resistance (\Omega)');
title('R_e and R_i Fit Values vs. Fit Max Freq.')

end

