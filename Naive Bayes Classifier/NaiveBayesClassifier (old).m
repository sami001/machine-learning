function [] = NaiveBayesClassifier(  )
 %%%%%%%%%%%%implement2tie!!!!!!!!!! %%%%%%%%%%%%%%%%%%%%%
 %%%resolve NAN value in first task%%%%%%%%%
 %%histogram WIDTH!!!!!!!!!!!!!%%
 
 
    trainingData = importdata('pendigits_training.txt');
    testData = importdata('pendigits_test.txt');
    INF = 100000000000;
    sum_accuracy = 0;
    
    Number = 3;
    task = 3;
      
    classes = unique(trainingData(:,end));
   
    for i = 1 : size(classes, 1)
        for j = 1 : (size(trainingData, 2) - 1)

            temp = trainingData(classes(i) == trainingData(:,end), j);
            PC(i) = size(temp, 1) / size(trainingData, 1);
           
            minColVal(i, j) = min(temp);
            maxColVal(i, j) = max(temp);
            
            S = minColVal(i, j);
            L = maxColVal(i, j);
            G = (L - S)/Number;
            
            if task == 1
                lo = -INF;
                hi = S+G;
                bin = 1;

                while bin <= Number
                    P(i, j, bin) = size(temp(temp >= lo & temp < hi), 1)/size(temp, 1);
                    if task == 1
                        fprintf('Class %d, attribute %d, bin %d, P(bin | class) = %.2f\n', classes(i), j - 1, bin - 1, P(i, j, bin));
                    end
                    bin = bin + 1;
                    lo = hi;
                    if bin < Number
                        hi = hi + G;
                    else
                        hi = INF;
                    end
                end
            elseif task == 2
                Mean(i, j) = mean(temp);
                Std(i, j) = std(temp);   
                if(Std(i, j)^2 < 0.0001)
                    Std(i, j) = sqrt(0.0001);
                end
                fprintf('Class %d, attribute %d, mean = %.2f, std = %.2f\n', classes(i), j - 1, Mean(i, j), Std(i, j));
                       
            elseif task == 3
                for k = 1: Number
                    MixedMean(i, j , k) = S + (k-1)*G + (G/2);
                    MixedStd(i, j, k) = 1;
                    MixedW(i, j, k) = (1/Number);
                    %disp(MixedMean(i, j, k));
                end

                for em = 1: 50
                    for ii = 1: Number                        
                        for jj = 1: size(temp, 1)
                            tempPG(ii, jj) = MixedW(i, j, ii) * normpdf(temp(jj), MixedMean(i, j, ii), MixedStd(i, j, ii));    
                          %  disp(PG(ii,jj));
                        %  fprintf('%f %f %f\n', temp(jj),MixedMean(i, j, ii), MixedStd(i, j, ii));
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
                       % disp(sum4(ii));
                        MixedMean(i, j, ii) = sum1/sum2;

                        for jj = 1: size(temp, 1)
                            sum3 = sum3 + PG(ii, jj)*((temp(jj) - MixedMean(i, j, ii))^2);
                        end
                        MixedStd(i, j, ii) = sqrt(sum3/sum2);
                        if(MixedStd(i, j, ii)^2 < 0.0001) 
                            MixedStd(i, j, ii) = sqrt(0.0001);
                        end
                    end

                    for ii = 1: Number
                        % M Step
                        MixedW(i, j, ii) = sum4(ii) / sum(sum4);
                    end
                end
                for k = 1: Number
                    fprintf('Class %d, attribute %d, Gaussian %d, mean = %.10f, std = %.10f\n', classes(i), j-1, k-1, MixedMean(i, j, k), MixedStd(i, j, k)); 
                end    
            end
            
        end
    end
    
    for i = 1 : size(testData, 1)
        for j = 1: size(classes, 1)
            PCA(j) = PC(j);
            for k = 1 : (size(testData,2) - 1)
                
                S = minColVal(j, k);
                L = maxColVal(j, k);
                G = (L - S)/Number;
                
                bin = 1;
                
                while ((testData(i, k) >= S+G) && (bin < Number))
                    bin = bin + 1;
                    G = G + 1;
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
        [val, idx] = max(PCA);

        if testData(i, end) == classes(idx)
            accuracy = 1;
        else
            accuracy = 0;
        end
        sum_accuracy = sum_accuracy + accuracy;
        fprintf('ID=%5d, predicted=%3d, probability = %.4f, true=%3d, accuracy=%4.2f\n', i-1, classes(idx), val/sum(PCA), testData(i, end), accuracy);
    end
    fprintf('classification accuracy=%6.4f\n', sum_accuracy / size(testData, 1));
end
