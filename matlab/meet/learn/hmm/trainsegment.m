function model = trainsegment(Y, X, restNDX, nRest)
% ARGS
% Y, X  - training data.
% nRest (optional) - number of mixtures for the rest model (default is 1).

if nargin < 4, nRest = 1; end

[rest, gesture] = separaterest(Y, X, restNDX);

if nRest == 1
  [model.restMu, model.restSigma, model.restMixmat] = singlegauss(rest);
else
  [model.restMu, model.restSigma, model.restMixmat] = mixgauss(rest, nRest);
end

model.gestureMu = mean(gesture, 2);
model.gestureSigma = diag(var(gesture, 0, 2));
end

function [mu, Sigma, mixmat] = mixgauss(X, nM)
NS = 1;
nX = size(X, 1);
[mu, Sigma, mixmat] = mixgauss_init(nM, X, 'diag'); 
mu = reshape(mu, [nX NS nM]);
Sigma = reshape(Sigma, [nX nX NS nM]);
mixmat = reshape(mixmat, [NS nM]);
end

function [mu, Sigma, mixmat] = singlegauss(X)
mu = mean(X, 2);
Sigma = diag(var(X, 0, 2));
mixmat = 1;
end