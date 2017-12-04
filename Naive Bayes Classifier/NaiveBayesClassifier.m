function [] = NaiveBayesClassifier(varargin)
    trainingData = load(varargin{1});
    testData = load(varargin{2});
    if strcmp(varargin{3}, 'histograms')
        task = 1;
    elseif strcmp(varargin{3}, 'gaussians')
        task = 2;
    else
        task = 3;
    end
    Number = str2num(varargin{4});

    
    sum_accuracy = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% training %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
    classes = unique(trainingData(:,end));
   
    for i = 1 : size(classes, 1)
        for j = 1 : (size(trainingData, 2) - 1)

            temp = trainingData(classes(i) == trainingData(:,end), j);
            PC(i) = size(temp, 1) / size(trainingData, 1);
           
            minColVal(i, j) = min(temp);
            maxColVal(i, j) = max(temp);
            
            S = minColVal(i, j);
            L = maxColVal(i, j);
            
            if task == 1
                G = max((L - S)/(Number - 3), 0.0001);
            else
                G = (L - S)/Number;
            end
            
            if task == 1
                lo = -Inf;
                hi = S-(G/2);
                bin = 1;

                while bin <= Number
                    if (bin > 1 && bin < Number) 
                        P(i, j, bin) = size(temp(temp >= lo & temp < hi), 1)/(size(temp, 1) * G);
                    else
                        P(i, j, bin) = size(temp(temp >= lo & temp < hi), 1)/(size(temp, 1));
                    end
                    
                    fprintf('Class %d, attribute %d, bin %d, P(bin | class) = %.2f\n', classes(i), j - 1, bin - 1, P(i, j, bin));
                    
                    bin = bin + 1;
                    lo = hi;
                    if bin < Number
                        hi = hi + G;
                    else
                        hi = Inf;
                    end
                end
            elseif task == 2
                Mean(i, j) = mean(temp);
                Std(i, j) = max(std(temp), 0.01);   
 
                fprintf('Class %d, attribute %d, mean = %.2f, std = %.2f\n', classes(i), j - 1, Mean(i, j), Std(i, j));
                       
            elseif task == 3
                for k = 1: Number
                    MixedMean(i, j , k) = S + (k-1)*G + (G/2);
                    MixedStd(i, j, k) = 1;
                    MixedW(i, j, k) = (1/Number);
                end

                for em = 1: 50
                    for ii = 1: Number                        
                        for jj = 1: size(temp, 1)
                            tempPG(ii, jj) = MixedW(i, j, ii) * normpdf(temp(jj), MixedMean(i, j, ii), MixedStd(i, j, ii));    
                        end
                    end
                    
                    sum4 = zeros;
                    for ii = 1: Number
                        sum1 = 0;
                        sum2 = 0;
                        sum3 = 0;
                        for jj = 1: size(temp, 1)
                            PG(ii, jj) = tempPG(ii, jj) / sum(tempPG(:, jj));
                            sum1 = sum1 + PG(ii, jj)*temp(jj);
                            sum2 = sum2 + PG(ii, jj);
                        end
                        % M Step
                        sum4(ii) = sum2;
                        MixedMean(i, j, ii) = sum1/sum2;

                        for jj = 1: size(temp, 1)
                            sum3 = sum3 + PG(ii, jj)*((temp(jj) - MixedMean(i, j, ii))^2);
                        end
                        MixedStd(i, j, ii) = max(sqrt(sum3/sum2), 0.01);
                    end

                    for ii = 1: Number
                        % M Step
                        MixedW(i, j, ii) = sum4(ii) / sum(sum4);
                    end
                end
                for k = 1: Number
                    fprintf('Class %d, attribute %d, Gaussian %d, mean = %.2f, std = %.2f\n', classes(i), j-1, k-1, MixedMean(i, j, k), MixedStd(i, j, k)); 
                end    
            end
            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% testing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1 : size(testData, 1)
        for j = 1: size(classes, 1)
            PCA(j) = PC(j);
            for k = 1 : (size(testData,2) - 1)
                
                S = minColVal(j, k);
                L = maxColVal(j, k);
                if task == 1
                    G = max((L - S)/(Number - 3), 0.0001);
                else
                    G = (L - S)/Number;
                end
                
                bin = 1;
                
                GG = 0;
                while ((testData(i, k) >= S-(G/2) + GG) && (bin < Number))
                    bin = bin + 1;
                    GG = GG + G;
                end
                 
                if task == 1
                    PCA(j) = PCA(j) * P(j, k, bin);
                elseif task == 2
                    PCA(j) = PCA(j) * normpdf(testData(i, k), Mean(j, k), Std(j, k));
                elseif task == 3
                    MG = 0;
                    for l = 1: Number
                        MG = MG + MixedW(j, k, l)*normpdf(testData(i, k), MixedMean(j, k, l), MixedStd(j, k, l));
                    end
                    PCA(j) = PCA(j) * MG;   
                end
            end
        end
        
        maxPCA = max(PCA);
        maxCount = 0;
        trueMax = 0;
        
        for j = 1: size(classes, 1)
            if maxPCA == PCA(j)
                maxIdx = j;
                maxCount = maxCount + 1;
                if classes(j) == testData(i, end)
                    trueMax = 1;
                end
            end
        end
           
        accuracy = trueMax/maxCount;
 
        sum_accuracy = sum_accuracy + accuracy;
        fprintf('ID=%5d, predicted=%3d, probability = %.4f, true=%3d, accuracy=%4.2f\n', i-1, classes(maxIdx), maxPCA/sum(PCA), testData(i, end), accuracy);
        
    end
    fprintf('classification accuracy=%6.4f\n', sum_accuracy / size(testData, 1));
end
