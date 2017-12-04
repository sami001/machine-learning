function [] = pca_power( varargin )
    trainingData = load(varargin{1});
    testData = load(varargin{2});
    M = str2num(varargin{3});
    it = str2num(varargin{4});
    x = trainingData(:,[1 : end-1]);
    y = testData(:,[1 : end-1]);
    D = size(x,2);
    N = size(x,1);
    U = zeros(M,D);
    for i = 1: M     
        s = cov(x);
        u = rand(D, 1);
        for j = 1:it
           temp = s*u;
           u = normc(temp);
        end
        U(i,:) = (u.');
        fprintf('Eigenvector %d\n', i);
        for j = 1:D
            fprintf('  %d: %.4f\n', j, u(j));
        end
        fprintf('\n');
        for n = 1: N
           x(n,:)= x(n,:) - ((u.')*(x(n,:).')*(u.'));
        end
    end
    for i = 1: size(y,1)
       fprintf('Test object %d\n', i-1);
       for j = 1: M
           fprintf('  %d: %.4f\n',j, U(j,:)*(y(i,:).'));
       end
       fprintf('\n');
    end
 end

