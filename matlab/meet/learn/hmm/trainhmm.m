function hmm = trainhmm(Y, X, param)
%% TRAINHMM trains an HMM model for every gesture class. Does not consider
% pre and post strokes.
%
% ARGS
% Y, X  - training labels and features.

% Cell array of sequences for each class.
XByClass = segmentbyclass(Y, X, param);

for i = 1 : param.vocabularySize
  if ~isempty(XByClass{i})
    d = size(XByClass{i}{1}, 1);
    break;
  end
end

model.prior = cell(param.vocabularySize, 1);
model.transmat = cell(param.vocabularySize, 1);
model.mu = cell(param.vocabularySize, 1); % d x nS x nM matrix
model.Sigma = cell(param.vocabularySize, 1);
model.term = cell(param.vocabularySize, 1);
model.mixmat = cell(param.vocabularySize, 1);
        
for i = 1 : param.vocabularySize
  nS = param.nS(i);
  if ~isempty(XByClass{i})
    rep = param.repeat(i);
    
    if nS > 1
      [prior0, transmat0, term0, mu0, Sigma0, mixmat0] = inithmmparam(...
          XByClass{i}, nS, param.nM(1), param.XcovType, 2, rep);
      [~, model.prior{i}, model.transmat{i}, model.mu{i}, model.Sigma{i}, ...
          model.mixmat{i}, model.term{i}] = mhmm_em(XByClass{i}, prior0, ...
          transmat0, mu0, Sigma0, mixmat0, 'adj_prior', 1, ...
          'max_iter', param.maxIter, 'cov_type', param.XcovType, ...
          'adj_Sigma', 1, 'term', term0);
    else
      [model.prior{i}, model.transmat{i}, model.mu{i}, ...
          model.Sigma{i}, model.mixmat{i}, ...
          model.term{i}] = makesimplehmmmodel(XByClass{i}, ...
          param.kinectSampleRate, param.nM, param.XcovType);
    end
  else
    nM = param.nM(2);
    model.prior{i} = zeros(nS, 1);
    model.transmat{i} = zeros(nS, nS);
    model.mu{i} = zeros(d, nS, nM);
    model.Sigma{i} = repmat(eye(d, d), 1, 1, nS, nM);
    model.mixmat{i} = zeros(nS, nM);
    model.term{i} = zeros(nS, 1);
  end
end

hmm.type = 'hmm';
hmm.model = combinetoonehmm(model.prior, model.transmat, model.term, ...
    model.mu, model.Sigma, model.mixmat, param);
end