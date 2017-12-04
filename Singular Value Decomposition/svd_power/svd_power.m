function [] = svd_power( varargin )
    A = load(varargin{1});
    M = str2num(varargin{2});
    it = str2num(varargin{3});
    D = size(A,2);
    N = size(A,1);
    U = zeros(M,7);
    U = eigenvectors(A * (A.'), M, it).';
    V = eigenvectors((A.')*A, M, it).';
    S = zeros(M,M);
    s = A * (A.');
    for i=1:M
        ev = U(:,i);
        evalue = ev'*s*ev;
        S(i,i) = evalue.^0.5;
        s = s - evalue*(ev*ev');
    end
    
    fprintf('Matrix U:\n');
    printMatrix(U);
    fprintf('\nMatrix S:\n');
    printMatrix(S);
    fprintf('\nMatrix V:\n');
    printMatrix(V);
    fprintf('\nReconstruction (U*S*V''):\n');
    printMatrix(U*S*V');
end

function [] = printMatrix(M)
    for i=1:size(M,1)
        fprintf('Row   %d:', i);
        for j=1: size(M,2)
            fprintf(' %8.4f', M(i,j));
        end
        fprintf('\n');
    end
end

function [out] = eigenvectors(in, M, it)
    for i = 1: M
        u = ones(size(in, 2), 1);
        for j = 1:it
           u = normc(in*u);
        end
        out(i,:) = u;
        for n = 1: size(in,1)
           in(n,:)= in(n,:) - ((u.')*(in(n,:).')*(u.'));
        end
    end
end
 

