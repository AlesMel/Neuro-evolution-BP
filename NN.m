classdef NN
    %   NN trieda na vytvorenie neuronovej siete.
    %   Vstupnymi arugmentami je populacia vo forme matice. Napriklad
    %   matica [100 50] kde je prva populacia o velkosti 100 jedincov,
    %   druha o velkosti 50 jedincov. 2. vstupnym argumentov je pocet
    %   neuronov vo vrstvach, napriklad [1 10 10 1] kde je 1 vstupny neuron
    %   10 skrytych neuronov, 10 skrytych neuronov a 1 vystupny neuron.
    %   Tretim vstupnym argumentom je aktivacna funkcia: 1 - Hyperbolicky

    properties
        populationSizes = [];
        populations = struct;
        inputNeurons = 0;
        hiddenLayer = [];
        outputNeurons = 0;
        weightsSizes = [];
        biasesSizes = [];
        space = [];
        
        weights = struct;

        fits = struct; % fitness
        fitTrend = struct; % trend of fitness
        fitsSep = struct; % separate fitness
        bestIndex = 0;

        activationFunction = 1;
        spaceLength = 0;

    end

    properties (Access = private)
    end

    methods
        function obj = NN(populations, neurons, mode)
            obj.populationSizes = populations;
            obj = obj.processNeurons(neurons);
            obj = obj.calcWeights();
            obj = obj.calcBiasesLength();
            obj = obj.processSpace(1);
            obj = obj.initializePopulations(mode);
            obj = obj.initializeFitnesses();
            obj = obj.initializeWeights();
        end

        % strucne vypisanie parametrov neuronovej siete
        function params = getParams(obj)
            params = struct('InputNeurons', obj.inputNeurons, 'HiddenLayer', obj.hiddenLayer, 'OutputNeurons', obj.outputNeurons, 'Weights', obj.weightsSizes);
        end

        % priestor v ktorom pracujeme
        function obj = processSpace(obj, M1)
            % M je matica multiplikacie vyhladaveho priestoru
            obj = obj.calcSpaceLength();
            obj.space = [-M1 * ones(1, obj.spaceLength); M1 * ones(1, obj.spaceLength)];  % range
        end

        function obj = changeActivationFunction(obj, activation)
            obj.activationFunction = activation;
        end

        % premene vektora chromoyomu/jedinca na vahy
        function [obj, weights] = convertWeights(obj, popIndex, geneIndex)
            lastPosition = 1;
            popString = sprintf("pop%d", popIndex); % get population field
            w = obj.populations.(popString)(geneIndex, lastPosition:lastPosition+obj.weightsSizes(1,1)-1);
            weights.("W1") = reshape(w, obj.hiddenLayer(1,1), obj.inputNeurons);
            hiddenLayerLength = length(obj.hiddenLayer(1,:));

            for j = 1:hiddenLayerLength - 1
                weightString = sprintf("W%d", j+1); % create field for weight
                w = obj.populations.(popString)(geneIndex, lastPosition:lastPosition+obj.weightsSizes(1,j+1)-1);
                weights.(weightString) = reshape(w, obj.hiddenLayer(1,j+1), obj.hiddenLayer(1,j));
                obj.weights.(popString).(weightString)(geneIndex, :) = w;
                lastPosition = lastPosition + obj.weightsSizes(1,j);
            end

            weightString = sprintf("W%d", hiddenLayerLength+1); % create field for weight
            w = obj.populations.(popString)(geneIndex, lastPosition:lastPosition+obj.weightsSizes(1,end)-1);
            weights.(weightString) = reshape(w, obj.outputNeurons, obj.hiddenLayer(1,end));
            obj.weights.(popString).(weightString)(geneIndex, :) = w;

            for k = 1:length(obj.biasesSizes(1,:))
                biasString = sprintf("B%d", k); % create field for weight
                weights.(biasString) = obj.populations.(popString)(geneIndex, lastPosition:lastPosition+obj.biasesSizes(1,k)-1)';
                obj.weights.(popString).(biasString)(geneIndex, :) = weights.(biasString);
                lastPosition = lastPosition + obj.biasesSizes(1,k);
            end
        end

        % aktualizacia vah
        function obj = updateWeights(obj, popIndex)
            for g = 1:obj.populationSizes(1,popIndex)
                lastPosition = 1;
                popString = sprintf("pop%d", popIndex); % get population field
                obj.weights.(popString).("W1")(g,:) =  obj.populations.(popString)(g, lastPosition:lastPosition+obj.weightsSizes(1,1)-1);
                hiddenLayerLength = length(obj.hiddenLayer(1,:));
                for j = 1:hiddenLayerLength - 1
                    weightString = sprintf("W%d", j+1); % create field for weight 
                    obj.weights.(popString).(weightString)(g,:)  = obj.populations.(popString)(g, lastPosition:lastPosition+obj.weightsSizes(1,j+1)-1);
                    lastPosition = lastPosition + obj.weightsSizes(1,j);
                end
  
                weightString = sprintf("W%d", hiddenLayerLength+1); % create field for weight
                obj.weights.(popString).(weightString)(g,:) = obj.populations.(popString)(g, lastPosition:lastPosition+obj.weightsSizes(1,end)-1);
    
                for k = 1:length(obj.biasesSizes(1,:))
                    biasString = sprintf("B%d", k); % create field for weight
                    obj.weights.(popString).(biasString)(g,:) =  obj.populations.(popString)(g, lastPosition:lastPosition+obj.biasesSizes(1,k)-1)';
                    lastPosition = lastPosition + obj.biasesSizes(1,k);
                end
            end   
        end

        % vyhodnotenie siete
        function out = evaluateOutput(obj, input, shifts, weights, popIndex, geneIndex)
            hiddenLayerLength = length(obj.hiddenLayer(1,:));

            if isrow(input)
                input = input';
            end
            
            A = (weights.("W1") * input) + weights.("B1");
            out = tanh(A);

            for i = 2:hiddenLayerLength
                weightString = sprintf("W%d", i);
                biasString = sprintf("B%d", i-1);
                A = (weights.(weightString) * out) + weights.(biasString);
                out = tanh(A);
            end

            weightString = sprintf("W%d", i+1);
            out = tanh((weights.(weightString) * out));
            for i = 1:length(shifts)
                out(i) = out(i) * shifts(i);
            end
        end

        % aktualizacia fitness hodnoty danej populacie
        function obj = updateFit(obj, popIndex, newFit)
            fitString = sprintf('fit%d', popIndex);
            obj.fits.(fitString) = newFit;
        end

        % aktualizacia urcitej populacie
        function obj = updatePop(obj, popIndex, newPop)
            popString = sprintf('pop%d', popIndex);
            obj.populations.(popString) = newPop;
            obj = obj.updateWeights(popIndex);
        end

        % zresetovanie populacie
        function [obj, pop] = resetPop(obj, popIndex)
            popString = sprintf('pop%d', popIndex);
            pop = zeros(obj.populationSizes(popIndex), obj.spaceLength);
            obj.populations.(popString) = pop;
        end

        % vlozenie trendu fitness funkcie
        function [obj] = fitTrendInsert(obj, popIndex, gen, fit)
            popString = sprintf('pop%d', popIndex);            
            obj.fitTrend.(popString)(gen, 1) = fit;
        end
        
        % vlozenie separatnej fitness funkcie, kde dostaneme jednotlive
        % zlozky
        function obj = fitSepInsert(obj, popIndex, gen, fit)
            popString = sprintf('pop%d', popIndex);            
            obj.fitsSep.(popString)(gen, :) = fit;
        end

        % zahriatie populacie
        function [obj, pop] = warmPop(obj, popIndex, alpha)
            popString = sprintf('pop%d', popIndex);
            pop = (2 * rand(obj.populationSizes(popIndex), obj.spaceLength) - 1) * alpha + ones(obj.populationSizes(popIndex), obj.spaceLength);
            obj.populations.(popString) = pop;
        end

        % vyber najlepsieho jedinca
        function obj = selectBest(obj, popIndex, size)
            popString = sprintf('pop%d', popIndex);
            fitString = sprintf('fit%d', popIndex);

            fit = obj.fits.(fitString);
            [~, index] = min(fit);
            obj.bestIndex = index;
            pp = ones(size, obj.spaceLength);
            pp = pp .* obj.populations.(popString)(index, :);
        end
    end

    methods (Access = private)
        % spracovanie neuronov vo vrstvach
        function obj = processNeurons(obj, neurons)
            obj.inputNeurons = neurons(1,1);
            obj.hiddenLayer = neurons(1,2:end-1);
            obj.outputNeurons = neurons(1,end);
        end

        % vypocitanie vah medzi neuronmi
        function obj = calcWeights(obj)
            hLayerLength = length(obj.hiddenLayer(1,:));
            obj.weightsSizes = zeros(1, hLayerLength);
            obj.weightsSizes(1, 1) = obj.inputNeurons * obj.hiddenLayer(1); % pocet vah medzi vstupnou vrstvou a prvou skrytou vrstvou

            for n = 1:hLayerLength-1
                obj.weightsSizes(n+1) = obj.hiddenLayer(n) * obj.hiddenLayer(n+1); % pocet vah medzi n skrytou vrstvou a n+1 skrytou vrstvou
            end
            obj.weightsSizes(1, end+1) = obj.hiddenLayer(1, end) * obj.outputNeurons; % pocet vah medzi poslednou skrytou vrstvou a vystupnou vrstvou
        end

        % vypocitanie dlzok biasov
        function obj = calcBiasesLength(obj)
            obj.biasesSizes = obj.hiddenLayer;
        end

        % vypocitanie priestoru (celkovo vahy a biasy)
        function obj = calcSpaceLength(obj)
            obj.spaceLength = sum(obj.weightsSizes(1,:)) + sum(obj.biasesSizes(1,:));
        end

        % inicializacie vah na prazdne vektory
        function obj = initializeWeights(obj)
            for i = 1:length(obj.populationSizes(1,:))
                for g = 1:obj.populationSizes(1,i)
                    lastPosition = 1;
                    popString = sprintf("pop%d", i); % get population field
                    obj.weights.(popString).("W1")(g,:) =  obj.populations.(popString)(g, lastPosition:lastPosition+obj.weightsSizes(1,1)-1);
                    hiddenLayerLength = length(obj.hiddenLayer(1,:));
                    for j = 1:hiddenLayerLength - 1
                        weightString = sprintf("W%d", j+1); % create field for weight 
                        obj.weights.(popString).(weightString)(g,:)  = obj.populations.(popString)(g, lastPosition:lastPosition+obj.weightsSizes(1,j+1)-1);
                        lastPosition = lastPosition + obj.weightsSizes(1,j);
                    end
      
                    weightString = sprintf("W%d", hiddenLayerLength+1); % create field for weight
                    obj.weights.(popString).(weightString)(g,:) = obj.populations.(popString)(g, lastPosition:lastPosition+obj.weightsSizes(1,end)-1);
        
                    for k = 1:length(obj.biasesSizes(1,:))
                        biasString = sprintf("B%d", k); % create field for weight
                        obj.weights.(popString).(biasString)(g,:) =  obj.populations.(popString)(g, lastPosition:lastPosition+obj.biasesSizes(1,k)-1)';
                        lastPosition = lastPosition + obj.biasesSizes(1,k);
                    end
                end
            end
        end
        
        % inicializacia populacie
        function obj = initializePopulations(obj, mode)
            for i = 1:length(obj.populationSizes(1, :))
                string = sprintf("pop%d", i);
                switch mode
                    case 1
                        obj.populations.(string) = zeros( obj.populationSizes(1,i),length(obj.space(1,:)));
                    case 2
                        clear pop;
                        for j = 1:obj.populationSizes(1, i)
                            for k = 1:length(obj.space(1,:))
                                pop(j, k) = (obj.space(2,k) - obj.space(1,k)) * rand() + obj.space(1,k);
                            end
                        end
                        obj.populations.(string) = pop;
                end
            end
        end
    
        % inicializacia fitness funkcie
        function obj = initializeFitnesses(obj)
            for i = 1:length(obj.populationSizes(1, :))
                string = sprintf("fit%d", i);
                obj.fits.(string) = zeros(obj.populationSizes(1, i), 1);
            end
        end

    end
end

