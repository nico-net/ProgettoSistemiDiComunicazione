function helperPlotter(newCodeRate, newModOrder)
    persistent codeRates modOrders timeStep ax1 ax2;
    
    if isempty(codeRates)
        codeRates = [];
        modOrders = [];
        timeStep = 0;
        
        % Figure con due subplot
        figure;
        ax1 = subplot(2,1,1);
        plot(ax1, NaN, NaN, 'b', 'LineWidth', 2);
        title(ax1, 'Code Rate nel Tempo');
        xlabel(ax1, 'Tempo');
        ylabel(ax1, 'Code Rate');
        yticks(ax1, [1/4, 1/2, 3/4]);
        yticklabels(ax1, {'1/2', '2/3', '3/4'});
        ylim([0, 1]);
        grid(ax1, 'on');
        hold(ax1, 'on');
        
        ax2 = subplot(2,1,2);
        plot(ax2, NaN, NaN, 'r', 'LineWidth', 2);
        title(ax2, 'Modulation Order nel Tempo');
        xlabel(ax2, 'Tempo');
        ylabel(ax2, 'Modulation Order');
        yticks(ax2, [1/4, 1/2, 3/4]);
        yticklabels(ax2, {'4', '16', '64'});
        ylim([0, 1]);
        grid(ax2, 'on');
        hold(ax2, 'on');
    end
    
    % Aggiornamento dei dati
    timeStep = timeStep + 1;
    [newCodeRate, newModOrder] = normalizeModCoder(newModOrder, newCodeRate);
    codeRates = [codeRates, newCodeRate];
    modOrders = [modOrders, newModOrder];
    
    subplot(2,1,1);
    if timeStep>1
        plot(1:timeStep, codeRates, 'b', 'LineWidth', 2);
        xlim([max(1, timeStep-20), timeStep]);
        
        subplot(2,1,2);
        plot(1:timeStep, modOrders, 'r', 'LineWidth', 2);
        xlim([max(1, timeStep-20), timeStep]);
        
        drawnow;
    end
end


function [newCodeRate, newModOrder] = normalizeModCoder(newModOrder, newCodeRate)
    switch newModOrder
        case 4
            newModOrder = 1/4;
        case 16
            newModOrder = 1/2;
        case 64
            newModOrder = 3/4;
    end
    switch newCodeRate
        case 1/2
            newCodeRate = 1/4;
        case 2/3
            newCodeRate = 1/2;
        case 3/4
            newCodeRate = 3/4;
    end
end