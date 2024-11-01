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
    
    params0 = [...
               {'plotchans'}, {chs2Plot}                           , ... % indices of channels to plot
               {'plotrad'  }, {0.36}                               , ... % plot radius
               {'headrad'  }, {max([EEGPos.locs(chs2Plot).radius])}, ... % head radius
               {'intrad'   }, {0.4}                                , ... % interpolate radius
               {'conv'     }, {'on'}                               , ... % plot radius just covers maximum channel radius
               {'colormap' }, {'jet'}                              , ... % colormap
               {'emarker'  }, {{'o', 'k', size0, 1}}               , ... % {MarkerType, Color, Size, LineWidth}
              ];           
    
    if ~isempty(chsMark)
        params = [params0, ...
                  {'emarker2'}, {{find(ismember(chs2Plot, chsMark)), '.', 'k', sizeMark, 1}}, ... % {Channels, MarkerType, Color, Size, LineWidth}
                 ];
    else
        params = params0;
    end

    return;
end