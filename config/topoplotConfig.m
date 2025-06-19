%% Topoplot config
function params = topoplotConfig(EEGPos, chsMark, size0, sizeMark)
    narginchk(1, 4);

    if nargin < 2
        chsMark = [];
    end
    
    if nargin < 3
        size0 = 4;
    end
    
    if nargin < 4
        sizeMark = 15;
    end
    
    chs2Plot = EEGPos.channels(~ismember(EEGPos.channels, EEGPos.ignore))';

    if size0 ~= 0
        marker = [{'emarker'}, {{'o', 'k', size0, 1}}]; % {MarkerType, Color, Size, LineWidth}
    else
        marker = [{'electrodes'}, {{'off'}}];
    end
    
    if EEGPos.name == "Neuroscan64"
        params0 = [...
                   {'plotchans'}, {chs2Plot}                           , ... % indices of channels to plot
                   {'plotrad'  }, {0.36}                               , ... % plot radius
                   {'headrad'  }, {max([EEGPos.locs(chs2Plot).radius])}, ... % head radius
                   {'intrad'   }, {0.4}                                , ... % interpolate radius
                   {'conv'     }, {'on'}                               , ... % plot radius just covers maximum channel radius
                   {'colormap' }, {flipud(slanCM('RdYlBu'))}           , ... % colormap
                   marker
                  ];
    elseif EEGPos.name == "Neuracle64"
        % reset location
        EEGPos.locs = readlocs('Neuracle_chan64.loc');
        params0 = [...
                   {'plotchans'}, {chs2Plot}                           , ... % indices of channels to plot
                   {'plotrad'  }, {0.64}                               , ... % plot radius
                   {'headrad'  }, {0.58}                               , ... % head radius
                   {'intrad'   }, {0.64}                               , ... % interpolate radius
                   {'conv'     }, {'on'}                               , ... % plot radius just covers maximum channel radius
                   {'colormap' }, {flipud(slanCM('RdYlBu'))}           , ... % colormap
                   marker
                  ];
    else
        error("Unsupported configuration");
    end
    
    if ~isempty(chsMark)
        params = [params0, ...
                  {'emarker2'}, {{find(ismember(chs2Plot, chsMark)), '.', 'k', sizeMark, 1}}, ... % {Channels, MarkerType, Color, Size, LineWidth}
                 ];
    else
        params = params0;
    end

    return;
end