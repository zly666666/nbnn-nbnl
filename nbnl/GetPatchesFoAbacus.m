function [features, labels, dataInfo, scalingFactor, trainingMean, Ured] = GetPatchesForAbacus(dataFolder, split, test_or_train, oldScalingFactor, oldMean, oldUred)
    DATA_SIZE = 'single';
    FEATURE_SIZE = 4096 + 2;
    dir_name = strcat(dataFolder, test_or_train,'/split_', num2str(split),'/')
    files = dir(strcat(dir_name,'*.hdf5'));

    dataInfo = struct([]);
    k = 1;
    disp 'Extracting feature size information'
    patchCount = 0;
    for file = files'
        file_name = strcat(dir_name,file.name);
        image_index = h5read(file_name,'/image_index');
        nCount = max(max(image_index));
        patchCount = patchCount + nCount;
        
        % Saving metadata on the features
        dataInfo(k).im_index = image_index;
        dataInfo(k).name = file_name;
        dataInfo(k).patchCount = nCount;
        k = k+1;
    end
    fprintf('There are %d patches in total\nLoading patches in memory...\n',patchCount);
    features = zeros(FEATURE_SIZE, patchCount, DATA_SIZE);
    labels = zeros(patchCount, 1, DATA_SIZE);
    classes = size(dataInfo,2)
    startPatch = 1;
    for c = 1:classes   
        file_name = dataInfo(c).name;
        fprintf('Loading file: %s\n', file_name);
        lastPatch = dataInfo(c).patchCount;
        patches = h5read(file_name,'/patches');
        positions = h5read(file_name,'/positions');
        features(:, startPatch:startPatch+lastPatch-1) = [patches(:,1:lastPatch); positions(:,1:lastPatch)/20];
        labels(startPatch:startPatch+lastPatch-1) = c;
        startPatch = startPatch + lastPatch;
    end
%     scalingMatrix  = repmat( 1./scalingFactor, 1,  size(features,2) );
%     features = features .* scalingMatrix;
    if nargin < 6
        disp('Computing reduced PCA transform');
        Ured = getPCATransform(features);
    else
        Ured = oldUred;
    end
    scalingFactor = 0;
    trainingMean = 0;
    disp('Applying PCA reduction');
    features = Ured'*features;

end
